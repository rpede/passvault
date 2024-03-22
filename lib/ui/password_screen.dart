import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/vault_cubit.dart';
import '../core/vault_state.dart';
import 'vault_screen.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter your master password"),
        centerTitle: true,
      ),
      body: BlocConsumer<VaultCubit, VaultState>(
        listenWhen: (previous, current) => current.status == VaultStatus.open,
        listener: (context, state) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const VaultScreen()),
          );
        },
        builder: (context, state) {
          return switch (state.status) {
            VaultStatus.absent => PasswordForm(
                onSubmit: (password) =>
                    context.read<VaultCubit>().createVault(password),
                buttonText: "Create",
              ),
            VaultStatus.closed => PasswordForm(
                onSubmit: (password) =>
                    context.read<VaultCubit>().openVault(password),
                buttonText: "Open",
              ),
            _ => const Center(child: CircularProgressIndicator.adaptive()),
          };
        },
      ),
    );
  }
}

class PasswordForm extends StatefulWidget {
  final Function(String password) onSubmit;
  final String buttonText;

  const PasswordForm({
    super.key,
    required this.onSubmit,
    required this.buttonText,
  });

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(_passwordController.text);
  }

  String? _passwordValidator(String? value) {
    const minLength = 8;
    final invalid = value == null || value.length < minLength;
    return invalid ? "Must be at least $minLength" : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 16)),
          const Text("Password"),
          TextFormField(
            controller: _passwordController,
            validator: _passwordValidator,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            onChanged: (newValue) => _formKey.currentState!.validate(),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16)),
          Center(
            child: ElevatedButton(
              onPressed: _handleSubmit,
              child: Text(widget.buttonText),
            ),
          ),
        ]),
      ),
    );
  }
}
