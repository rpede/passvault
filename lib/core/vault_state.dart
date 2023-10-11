import 'package:equatable/equatable.dart';

import 'vault_data.dart';

abstract class VaultState {}

class InitialState implements VaultState {}

abstract class LoadingState implements VaultState {}

class InitializingState implements LoadingState {}

class InitializedState extends Equatable implements VaultState {
  final bool vaultExists;
  InitializedState(this.vaultExists);

  @override
  List<Object?> get props => [vaultExists];
}

class CreatingState extends LoadingState {}

class OpeningState extends LoadingState {}

class SavingState extends LoadingState {}

class OpenState implements VaultState {
  final VaultData data;
  OpenState(this.data);
}

class ErrorState implements VaultState {
  final String message;
  ErrorState(this.message);
}
