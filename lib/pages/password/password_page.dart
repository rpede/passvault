import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passvault/core/vault_cubit.dart';
import 'package:passvault/core/vault_state.dart';
import 'package:passvault/pages/vault/vault_page.dart';

import 'password_form.dart';

class PasswordPage extends StatelessWidget {
  const PasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vault = context.read<VaultCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text("PassVault")),
      body: BlocConsumer<VaultCubit, VaultState>(
        listener: (context, state) {
          switch (state) {
            case OpenState _:
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const VaultPage(),
              ));
            case ErrorState _:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(state.message),
                ),
              );
          }
        },
        builder: (context, state) {
          return switch (state) {
            InitializedState _ => PasswordForm(
                vaultExists: state is VaultExistsState,
                invalidPassword: state is InvalidPasswordState,
                onSubmitted: vault.enter,
              ),
            LoadingState _ => const Center(child: CircularProgressIndicator()),
            ErrorState _ => Center(
                child: TextButton(
                  onPressed: vault.delete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text("Clear"),
                ),
              ),
            VaultState state => Text(state.toString())
          };
        },
      ),
    );
  }
}
