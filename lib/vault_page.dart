import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passvault/vault_cubit.dart';
import 'package:passvault/vault_item_page.dart';
import 'package:passvault/vault_state.dart';

typedef MenuAction = void Function();

class VaultPage extends StatelessWidget {
  const VaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vault = context.read<VaultCubit>();
    return Scaffold(
      appBar: AppBar(title: Text("Your Vault")),
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
        final items = (state as OpenState).data;
        return ListView.separated(
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text(item.username),
              trailing: PopupMenuButton<MenuAction>(
                onSelected: (MenuAction action) => action.call(),
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<MenuAction>>[
                  PopupMenuItem<MenuAction>(
                    value: () =>
                        Clipboard.setData(ClipboardData(text: item.username)),
                    child: Text('Copy username'),
                  ),
                  PopupMenuItem<MenuAction>(
                    value: () =>
                        Clipboard.setData(ClipboardData(text: item.password)),
                    child: Text('Copy password'),
                  ),
                  PopupMenuItem<MenuAction>(
                    value: () async {
                      vault.removeItem(item);
                      vault.save();
                    },
                    child: Text('Remove'),
                  ),
                ],
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => VaultItemPage(item: item),
              )),
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: items.length,
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => VaultItemPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
