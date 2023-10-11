import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefKeys {
  static const Salt = "salt";
  static const Nonce = "nonce";
  static const Mac = "mac";
  static const Data = "data";
  static final All = [Salt, Nonce, Mac, Data];
}

class Storage {
  final SharedPreferences _prefs;

  Storage._(this._prefs);

  static Future<Storage> create() async {
    return Storage._(await SharedPreferences.getInstance());
  }

  bool get vaultExists => PrefKeys.All.every((key) => _prefs.containsKey(key));

  Future save(List<int> salt, SecretBox encrypted) {
    return Future.wait([
      _prefs.setString(PrefKeys.Salt, base64.encode(salt)),
      _prefs.setString(PrefKeys.Nonce, base64.encode(encrypted.nonce)),
      _prefs.setString(PrefKeys.Mac, base64.encode(encrypted.mac.bytes)),
      _prefs.setString(PrefKeys.Data, base64.encode(encrypted.cipherText)),
    ]);
  }

  Future<(List<int>, SecretBox)> load() async {
    final salt = base64.decode(_prefs.getString(PrefKeys.Salt)!);
    final encrypted = SecretBox(
      base64.decode(_prefs.getString(PrefKeys.Data)!),
      nonce: base64.decode(_prefs.getString(PrefKeys.Nonce)!),
      mac: Mac(base64.decode(_prefs.getString(PrefKeys.Mac)!)),
    );
    return (salt, encrypted);
  }

  delete() => _prefs.clear;
}
