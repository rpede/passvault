import 'dart:convert';

import 'package:passvault/core/vault_data.dart';

class Serializer {
  static String serialize(VaultData data) {
    return json.encode(data,
        toEncodable: (object) => vaultItemToMap(object as VaultItem));
  }

  static VaultData deserialize(String data) {
    return (json.decode(data) as List<dynamic>)
        .map((e) => vaultItemFromMap(e))
        .toList();
  }

  static VaultItem vaultItemFromMap(Map<String, dynamic> json) => VaultItem(
        name: json['name'],
        username: json['name'],
        password: json['password'],
      );

  static Map<String, dynamic> vaultItemToMap(VaultItem item) =>
      <String, dynamic>{
        'name': item.name,
        'username': item.username,
        'password': item.password,
      };
}
