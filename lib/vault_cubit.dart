import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cryptography/cryptography.dart';

import 'storage.dart';
import 'vault_data.dart';
import 'vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  late Storage storage;
  final KdfAlgorithm keyAlgorithm;
  final Cipher cipher;

  VaultCubit({required this.keyAlgorithm, required this.cipher})
      : super(InitialState());

  static VaultCubit safe() {
    return VaultCubit(
      keyAlgorithm: Argon2id(
        parallelism: 4,
        memory: 10000, // 10 000 x 1kB block = 10 MB
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
    emit(OpenState(key, data));
  }

  open(String password) async {
    assert(state == InitializedState(true));
    final result = await storage.load();
    final key = await keyAlgorithm.deriveKeyFromPassword(
        password: password, nonce: result.$1);
    final raw =
        json.decode(await cipher.decryptString(result.$2, secretKey: key));
    final data = (raw as List<dynamic>).map((e) => e as VaultItem).toList();
    emit(OpenState(key, data));
  }
}
