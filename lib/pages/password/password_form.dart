import 'package:flutter/material.dart';

class PasswordForm extends StatefulWidget {
  final bool vaultExists;
  final bool invalidPassword;
  final void Function(String password) onSubmitted;

  const PasswordForm({
    super.key,
    required this.vaultExists,
    required this.invalidPassword,
    required this.onSubmitted,
  });

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _tryAgain = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 16)),
          const Text("Enter you master password"),
          _passwordField(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16)),
          Center(
            child: _submitButton(),
          ),
        ]),
      ),
    );
  }

  TextFormField _passwordField() {
    return TextFormField(
      controller: _passwordController,
      validator: (value) {
        const minLength = 8;
        final invalid = value == null || value.length < minLength;
        return invalid ? "Must be at least ${minLength}" : null;
      },
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      onChanged: (newValue) => _formKey.currentState!.validate(),
    );
  }

  ElevatedButton _submitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          widget.onSubmitted(_passwordController.text);
        }
      },
      child: Text(
        widget.vaultExists
            ? widget.invalidPassword
                ? "Try again"
                : "Open"
            : "Create",
      ),
    );
  }
}
