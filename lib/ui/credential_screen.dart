import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/vault_cubit.dart';
import '../core/vault_state.dart';
import '../infrastructure/password_generator.dart';
import '../models/credential.dart';

class CredentialScreen extends StatefulWidget {
  final Credential? existingCredential;

  const CredentialScreen({super.key, this.existingCredential});

  @override
  State<CredentialScreen> createState() => _CredentialScreenState();
}

class _CredentialScreenState extends State<CredentialScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  var showPassword = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingCredential?.name);
    _usernameCtrl =
        TextEditingController(text: widget.existingCredential?.username);
    _passwordCtrl =
        TextEditingController(text: widget.existingCredential?.password);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void save() {
    final vault = context.read<VaultCubit>();
    final credential = Credential(
      name: _nameCtrl.text,
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
    );
    if (widget.existingCredential == null) {
      vault.addCredential(credential);
    } else {
      vault.updateCredential(credential);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Credential")),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            NameField(controller: _nameCtrl),
            UsernameField(controller: _usernameCtrl),
            PasswordField(controller: _passwordCtrl),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16)),
            SaveButton(onSave: save),
          ],
        ),
      ),
    );
  }
}

class UsernameField extends StatelessWidget {
  const UsernameField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(label: Text("Username")),
    );
  }
}

class NameField extends StatelessWidget {
  final TextEditingController controller;

  const NameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(label: Text("Name/Site")),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextFormField(
            controller: widget.controller,
            obscureText: !showPassword,
            decoration: const InputDecoration(label: Text("Password")),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
        IconButton.outlined(
          onPressed: () {
            setState(() => showPassword = !showPassword);
          },
          icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
        IconButton.outlined(
          onPressed: () {
            widget.controller.text = PasswordGenerator.generate();
          },
          icon: const Icon(Icons.casino),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  final Function() onSave;

  const SaveButton({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VaultCubit, VaultState>(builder: (context, state) {
      if (state.status == VaultStatus.saving) {
        return const CircularProgressIndicator();
      } else {
        return ElevatedButton(
          onPressed: onSave,
          child: const Text("Save"),
        );
      }
    });
  }
}
