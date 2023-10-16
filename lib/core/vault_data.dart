typedef VaultData = List<VaultItem>;

class VaultItem {
  final String name;
  final String username;
  final String password;

  const VaultItem({
    required this.name,
    required this.username,
    required this.password,
  });
}
