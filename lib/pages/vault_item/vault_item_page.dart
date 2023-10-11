import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passvault/core/vault_cubit.dart';
import 'package:passvault/core/vault_data.dart';
import 'package:passvault/core/vault_state.dart';
import 'package:passvault/infrastructure/password_generator.dart';

class VaultItemPage extends StatefulWidget {
  VaultItem? item;

  VaultItemPage({super.key, this.item});

  @override
  State<VaultItemPage> createState() => _VaultItemPageState();
}

class _VaultItemPageState extends State<VaultItemPage> {
  late final _nameCtrl;
  late final _usernameCtrl;
  late final _passwordCtrl;
  var showPassword = false;

  @override
  void initState() {
    _nameCtrl = TextEditingController(text: widget.item?.name);
    _usernameCtrl = TextEditingController(text: widget.item?.username);
    _passwordCtrl = TextEditingController(text: widget.item?.password);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add new item")),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _nameField(),
            _usernameField(),
            _passwordField(),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16)),
            _saveButton()
          ],
        ),
      ),
    );
  }

  Row _passwordField() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextFormField(
            controller: _passwordCtrl,
            obscureText: !showPassword,
            decoration: InputDecoration(label: Text("Password")),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
        IconButton.outlined(
          onPressed: () => setState(() => showPassword = !showPassword),
          icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
        IconButton.outlined(
            onPressed: () {
              _passwordCtrl.text = PasswordGenerator.generate();
            },
            icon: Icon(Icons.casino)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
      ],
    );
  }

  TextFormField _usernameField() {
    return TextFormField(
      controller: _usernameCtrl,
      decoration: InputDecoration(label: Text("Username")),
    );
  }

  TextFormField _nameField() {
    return TextFormField(
      controller: _nameCtrl,
      decoration: InputDecoration(label: Text("Name/Site")),
    );
  }

  BlocBuilder<VaultCubit, VaultState> _saveButton() {
    return BlocBuilder<VaultCubit, VaultState>(builder: (context, state) {
      if (state is SavingState) {
        return CircularProgressIndicator();
      } else {
        return ElevatedButton(
          onPressed: () async => await _onSave(context),
          child: const Text("Save"),
        );
      }
    });
  }

  Future _onSave(BuildContext context) async {
    final vault = context.read<VaultCubit>();
    final item = VaultItem(
      name: _nameCtrl.text,
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
    );
    if (widget.item == null) {
      vault.addItem(item);
    } else {
      vault.updateItem(widget.item!, item);
    }
    await vault.save();
    Navigator.of(context).pop();
  }
}
