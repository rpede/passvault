import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'credential.g.dart';

@JsonSerializable()
class Credential extends Equatable {
  final String name;
  final String username;
  final String password;

  const Credential({
    required this.name,
    required this.username,
    required this.password,
  });

  factory Credential.fromJson(Map<String, dynamic> json) =>
      _$CredentialFromJson(json);
  Map<String, dynamic> toJson() => _$CredentialToJson(this);

  @override
  List<Object?> get props => [name, username, password];

  @override
  String toString() => "$runtimeType($name, $username, ***)";
}
