import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passvault/vault_cubit.dart';
import 'package:passvault/vault_data.dart';
import 'package:passvault/vault_item_page.dart';
import 'package:passvault/vault_state.dart';

typedef MenuAction = void Function();

class VaultPage extends StatelessWidget {
  const VaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Vault")),
      body: BlocConsumer<VaultCubit, VaultState>(listener: (context, state) {
        switch (state) {
          case ErrorState _:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.message),
              ),
            );
        }
      }, builder: (context, state) {
        return switch (state) {
          OpenState s => ListView.separated(
              itemBuilder: (context, index) =>
                  VaultItemListTile(item: s.data[index]),
              separatorBuilder: (context, index) => Divider(),
              itemCount: s.data.length,
            ),
          LoadingState _ => const Center(child: CircularProgressIndicator()),
          VaultState s => Text("Unexpected state $s")
        };
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => VaultItemPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
