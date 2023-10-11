typedef VaultData = List<VaultItem>;

class VaultItem {
  final String name;
  final String username;
  final String password;

  VaultItem({
    required this.name,
    required this.username,
    required this.password,
  });

  static VaultItem fromJson(Map<String, dynamic> json) => VaultItem(
        name: json['name'],
        username: json['name'],
        password: json['password'],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'username': username,
        'password': password,
      };
}
