import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/encrypted_vault.dart';

class Storage {
  static const _key = 'data';
  final SharedPreferences _preferences;

  Storage._(this._preferences);

  bool get exits => _preferences.containsKey(_key);

  static Future<Storage> create() async {
    return Storage._(await SharedPreferences.getInstance());
  }

  Future<bool> save(EncryptedVault vault) =>
      _preferences.setString(_key, jsonEncode(vault.toJson()));

  EncryptedVault? load() {
    final json = _preferences.getString(_key);
    if (json == null) return null;
    return EncryptedVault.fromJson(jsonDecode(json));
  }

  delete() => _preferences.clear();
}
