import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'password_page.dart';
import 'vault_cubit.dart';

void main() {
  runApp(const PassVaultApp());
}

class PassVaultApp extends StatelessWidget {
  const PassVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => VaultCubit.safe()..initialize(),
        child: PasswordPage(),
      ),
    );
  }
}
