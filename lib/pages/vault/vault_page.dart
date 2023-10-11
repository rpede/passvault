import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passvault/core/vault_cubit.dart';
import 'package:passvault/core/vault_state.dart';
import 'package:passvault/pages/vault/vault_list.dart';
import 'package:passvault/pages/vault_item/vault_item_page.dart';

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
          OpenState s => VaultList(data: s.data),
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