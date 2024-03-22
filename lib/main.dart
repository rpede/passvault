import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';

import 'core/vault_api.dart';
import 'core/vault_cubit.dart';
import 'core/vault_state.dart';
import 'infrastructure/protection.dart';
import 'infrastructure/storage.dart';
import 'logger_bloc_observer.dart';
import 'ui/password_screen.dart';

void main() async {
  PrintAppender(formatter: const ColorFormatter()).attachToLogger(Logger.root);
  Bloc.observer = LoggerBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();
  final storage = await Storage.create();

  runApp(BlocProvider(
    create: (context) => VaultCubit(
      VaultApi(protector: Protection.sensibleDefaults(), storage: storage),
    ),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PasswordManager',
      home: BlocListener<VaultCubit, VaultState>(
          listenWhen: (previous, current) => current is FailedState,
          listener: (context, state) {
            final text = switch (state) {
              FailedToOpenState _ =>
                "Unable to open vault.\nDid you type the correct password?",
              _ => "An unknown error has occurred.\nSee log for details."
            };
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(text)));
          },
          child: const PasswordScreen()),
    );
  }
}
