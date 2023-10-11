import 'package:flutter/material.dart';
import 'package:passvault/core/vault_data.dart';
import 'package:passvault/pages/vault/vault_list_tile.dart';

class VaultList extends StatelessWidget {
  const VaultList({
    super.key,
    required this.data,
  });

  final VaultData data;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => VaultItemListTile(item: data[index]),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: data.length,
    );
  }
}
