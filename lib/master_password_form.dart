import 'package:flutter/material.dart';

class MasterPasswordForm extends StatefulWidget {
  final bool vaultExists;
  final void Function(String password) onSubmitted;

  const MasterPasswordForm({
    super.key,
    required this.vaultExists,
    required this.onSubmitted,
  });

  @override
  State<MasterPasswordForm> createState() => _MasterPasswordFormState();
}

class _MasterPasswordFormState extends State<MasterPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Enter you master password"),
          Padding(padding: EdgeInsets.symmetric(vertical: 16)),
          TextFormField(
            controller: _passwordController,
            validator: _passwordPolicy,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            onChanged: (newValue) => _formKey.currentState!.validate(),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 16)),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmitted(_passwordController.text);
                }
              },
              child: Text("Create"),
            ),
          ),
        ]),
      ),
    );
  }

  String? _passwordPolicy(String? value) {
    const minLength = 8;
    final invalid = value == null || value.length < minLength;
    return invalid ? "Must be at least ${minLength}" : null;
  }
}
