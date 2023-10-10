import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:cryptography/cryptography.dart';

import 'storage.dart';
import 'vault_data.dart';
import 'vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  final _log = Logger((VaultCubit).toString());

  late Storage storage;
  final KdfAlgorithm keyAlgorithm;
  final Cipher cipher;

  VaultCubit({required this.keyAlgorithm, required this.cipher})
      : super(InitialState());

  static VaultCubit safe() {
    return VaultCubit(
      keyAlgorithm: Argon2id(
        parallelism: 1,
        memory: 12288,
        iterations: 3,
        hashLength: 256 ~/ 8,
      ),
      cipher: AesGcm.with256bits(),
    );
  }

  initialize() async {
    assert(state is InitialState);
    emit(InitializingState());
    storage = await Storage.create();
    emit(InitializedState(storage.vaultExists));
  }

  enter(String password) async {
    assert(state is InitializedState);
    if ((state as InitializedState).vaultExists) {
      await open(password);
    } else {
      await create(password);
    }
  }

  create(String password) async {
    assert(state == InitializedState(false));
    emit(CreatingState());
    final data = VaultData.empty();
    final salt = List<int>.generate(32, (i) => SecureRandom.safe.nextInt(256));
    final key = await keyAlgorithm.deriveKeyFromPassword(
        password: password, nonce: salt);
    final encrypted =
        await cipher.encryptString(json.encode(data), secretKey: key);
    await storage.save(salt, encrypted);
    emit(OpenState(key, salt, data));
  }

  open(String password) async {
    assert(state == InitializedState(true));
    final result = await storage.load();
    final key = await keyAlgorithm.deriveKeyFromPassword(
        password: password, nonce: result.$1);
    try {
      final data =
          _deserialize(await cipher.decryptString(result.$2, secretKey: key));
      emit(OpenState(key, result.$1, data));
    } on SecretBoxAuthenticationError catch (e) {
      _log.severe(e);
      emit(ErrorState(e.message));
    }
  }

  delete() async {
    await storage.delete();
    emit(InitializedState(false));
  }

  addItem(VaultItem item) {
    assert(state is OpenState);
    final s = (state as OpenState);
    emit(OpenState(s.key, s.salt, [...s.data, item]));
  }

  updateItem(VaultItem oldItem, VaultItem newItem) {
    assert(state is OpenState);
    final s = (state as OpenState);
    final index = s.data.indexOf(oldItem);
    final newData = [...s.data];
    newData.removeAt(index);
    newData.insert(index, newItem);
    emit(OpenState(s.key, s.salt, newData));
  }

  removeItem(VaultItem item) {
    final s = (state as OpenState);
    final newData = [...s.data];
    newData.remove(item);
    emit(OpenState(s.key, s.salt, newData));
  }

  save() async {
    assert(state is OpenState);
    final s = (state as OpenState);
    emit(SavingState());
    final encrypted =
        await cipher.encryptString(_serialize(s.data), secretKey: s.key);
    await storage.save(s.salt, encrypted);
    emit(OpenState(s.key, s.salt, s.data));
  }

  _serialize(List<VaultItem> data) => json.encode(data,
      toEncodable: (object) => (object as VaultItem).toJson());

  _deserialize(dynamic data) => (json.decode(data) as List<dynamic>)
      .map((e) => VaultItem.fromJson(e))
      .toList();
}
