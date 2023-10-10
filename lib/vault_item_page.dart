import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passvault/password_generator.dart';
import 'package:passvault/vault_cubit.dart';
import 'package:passvault/vault_data.dart';
import 'package:passvault/vault_state.dart';

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
      appBar: AppBar(title: Text("Add new item")),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(label: Text("Name/Site")),
            ),
            TextFormField(
              controller: _usernameCtrl,
              decoration: InputDecoration(label: Text("Username")),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _passwordCtrl,
                    obscureText: !showPassword,
                    decoration: InputDecoration(label: Text("Password")),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
                IconButton.outlined(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(showPassword
                        ? Icons.visibility
                        : Icons.visibility_off)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
                IconButton.outlined(
                    onPressed: () {
                      _passwordCtrl.text = PasswordGenerator.generate();
                    },
                    icon: Icon(Icons.casino)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
              ],
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 16)),
            BlocBuilder<VaultCubit, VaultState>(builder: (context, state) {
              if (state is SavingState) {
                return CircularProgressIndicator();
              } else {
                return ElevatedButton(
                  onPressed: () async => await _save(context),
                  child: const Text("Save"),
                );
              }
            })
          ],
        ),
      ),
    );
  }

  Future _save(BuildContext context) async {
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
