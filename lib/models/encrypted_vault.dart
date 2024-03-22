import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'encrypted_vault.g.dart';

@JsonSerializable()
class EncryptedVault {
  @Base64Converter()
  final List<int> salt;
  @Base64Converter()
  final List<int> nonce;
  @Base64Converter()
  final List<int> mac;
  @Base64Converter()
  final List<int> cipherText;

  EncryptedVault({
    required this.salt,
    required this.nonce,
    required this.mac,
    required this.cipherText,
  });

  factory EncryptedVault.fromJson(Map<String, dynamic> json) =>
      _$EncryptedVaultFromJson(json);
  Map<String, dynamic> toJson() => _$EncryptedVaultToJson(this);
}

class Base64Converter implements JsonConverter<List<int>, String> {
  const Base64Converter();
  @override
  List<int> fromJson(String json) => base64Decode(json);

  @override
  String toJson(List<int> bytes) => base64Encode(bytes);
}
