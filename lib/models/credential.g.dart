// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Credential _$CredentialFromJson(Map<String, dynamic> json) => Credential(
      name: json['name'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$CredentialToJson(Credential instance) =>
    <String, dynamic>{
      'name': instance.name,
      'username': instance.username,
      'password': instance.password,
    };
