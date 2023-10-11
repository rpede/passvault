import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:cryptography/cryptography.dart';
import 'package:passvault/infrastructure/storage.dart';

import 'vault_data.dart';
import 'vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  final _log = Logger((VaultCubit).toString());

  late Storage storage;
  final KdfAlgorithm keyAlgorithm;
  final Cipher cipher;

  SecretKey? _key;
  List<int>? _salt;

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
    _salt = List<int>.generate(32, (i) => SecureRandom.safe.nextInt(256));
    _key = await keyAlgorithm.deriveKeyFromPassword(
        password: password, nonce: _salt!);
    final encrypted =
        await cipher.encryptString(json.encode(data), secretKey: _key!);
    await storage.save(_salt!, encrypted);
    emit(OpenState(data));
  }

  open(String password) async {
    assert(state == InitializedState(true));
    final result = await storage.load();
    _salt = result.$1;
    _key = await keyAlgorithm.deriveKeyFromPassword(
        password: password, nonce: result.$1);
    try {
      final data =
          _deserialize(await cipher.decryptString(result.$2, secretKey: _key!));
      emit(OpenState(data));
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
    emit(OpenState([...(state as OpenState).data, item]));
  }

  updateItem(VaultItem oldItem, VaultItem newItem) {
    assert(state is OpenState);
    final data = (state as OpenState).data;
    final index = data.indexOf(oldItem);
    final newData = [...data];
    newData.removeAt(index);
    newData.insert(index, newItem);
    emit(OpenState(newData));
  }

  removeItem(VaultItem item) {
    assert(state is OpenState);
    final data = (state as OpenState).data;
    final newData = [...data];
    newData.remove(item);
    emit(OpenState(newData));
  }

  save() async {
    assert(state is OpenState);
    final data = (state as OpenState).data;
    emit(SavingState());
    final encrypted =
        await cipher.encryptString(_serialize(data), secretKey: _key!);
    await storage.save(_salt!, encrypted);
    emit(OpenState(data));
  }

  _serialize(List<VaultItem> data) => json.encode(data,
      toEncodable: (object) => (object as VaultItem).toJson());

  _deserialize(dynamic data) => (json.decode(data) as List<dynamic>)
      .map((e) => VaultItem.fromJson(e))
      .toList();
}
