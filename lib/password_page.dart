import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'master_password_form.dart';
import 'vault_cubit.dart';
import 'vault_state.dart';

class PasswordPage extends StatelessWidget {
  const PasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vault = context.read<VaultCubit>();
    return Scaffold(
      appBar: AppBar(title: Text("PassVault")),
      body: BlocBuilder<VaultCubit, VaultState>(
        builder: (context, state) => vault.state is InitializedState
            ? MasterPasswordForm(
                vaultExists: (state as InitializedState).vaultExists,
                onSubmitted: vault.enter,
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
