import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../models/encrypted_vault.dart';
import '../models/open_vault.dart';
import '../models/credential.dart';

class Protection {
  final KdfAlgorithm kdfAlgorithm;
  final Cipher cipher;

  Protection({required this.kdfAlgorithm, required this.cipher});

  Protection.sensibleDefaults()
      : kdfAlgorithm = Argon2id(
          parallelism: 1,
          memory: 12288,
          iterations: 3,
          hashLength: 256 ~/ 8,
        ),
        cipher = AesGcm.with256bits();

  Future<Key> createKey(String masterPassword) async {
    final salt = generateSalt();
    final secretKey = await kdfAlgorithm.deriveKeyFromPassword(
        password: masterPassword, nonce: salt);
    return _Key(secretKey, salt: salt);
  }

  List<int> generateSalt() =>
      List<int>.generate(32, (i) => SecureRandom.safe.nextInt(256));

  Future<Key> recreateKey(EncryptedVault vault, String masterPassword) async {
    final secretKey = await kdfAlgorithm.deriveKeyFromPassword(
      password: masterPassword,
      nonce: vault.salt,
    );
    return _Key(secretKey, salt: vault.salt);
  }

  Future<List<Credential>> decrypt(
      EncryptedVault encryptedVault, Key key) async {
    final jsonString = await cipher.decryptString(
      encryptedVault.toSecretBox(),
      secretKey: (key as _Key).secretKey,
    );
    final json = jsonDecode(jsonString) as List<dynamic>;
    return List<Credential>.from(json.map((e) => Credential.fromJson(e)));
  }

  Future<EncryptedVault> encrypt(OpenVault openVault) async {
    final key = (openVault.key as _Key);
    final encrypted = await cipher.encryptString(
        jsonEncode(openVault.credentials),
        secretKey: key.secretKey);
    return encrypted.toEncryptedVault(salt: key.salt);
  }
}

sealed class Key {
  void destroy();
}

class _Key extends Key {
  final SecretKey secretKey;
  final List<int> salt;

  _Key(this.secretKey, {required this.salt});

  @override
  void destroy() {
    secretKey.destroy();
    salt.setAll(0, List.filled(salt.length, 0));
  }
}

extension EncryptedVaultX on EncryptedVault {
  SecretBox toSecretBox() => SecretBox(cipherText, nonce: nonce, mac: Mac(mac));
}

extension SecretBoxX on SecretBox {
  EncryptedVault toEncryptedVault({required List<int> salt}) {
    return EncryptedVault(
      salt: salt,
      nonce: nonce,
      mac: mac.bytes,
      cipherText: cipherText,
    );
  }
}
