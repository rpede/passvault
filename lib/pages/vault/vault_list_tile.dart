import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passvault/core/vault_cubit.dart';
import 'package:passvault/core/vault_data.dart';
import 'package:passvault/pages/vault/vault_page.dart';
import 'package:passvault/pages/vault_item/vault_item_page.dart';

class VaultItemListTile extends StatelessWidget {
  const VaultItemListTile({
    super.key,
    required this.item,
  });

  final VaultItem item;

  @override
  Widget build(BuildContext context) {
    final vault = context.read<VaultCubit>();
    return ListTile(
      title: Text(item.name),
      subtitle: Text(item.username),
      trailing: PopupMenuButton<MenuAction>(
        onSelected: (MenuAction action) => action.call(),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuAction>>[
          PopupMenuItem<MenuAction>(
            value: () => Clipboard.setData(ClipboardData(text: item.username)),
            child: const Text('Copy username'),
          ),
          PopupMenuItem<MenuAction>(
            value: () => Clipboard.setData(ClipboardData(text: item.password)),
            child: const Text('Copy password'),
          ),
          PopupMenuItem<MenuAction>(
            value: () async {
              vault.removeItem(item);
              vault.save();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => VaultItemPage(item: item),
      )),
    );
  }
}
