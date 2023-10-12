import 'package:equatable/equatable.dart';

import 'vault_data.dart';

abstract class VaultState {}

class InitialState implements VaultState {}

abstract class LoadingState implements VaultState {}

class InitializingState implements LoadingState {}

class InitializedState implements VaultState {}

class VaultDoesNotExistsState implements InitializedState {}

class VaultExistsState implements InitializedState {}

class InvalidPasswordState implements VaultExistsState {}

class CreatingState extends LoadingState {}

class OpeningState extends LoadingState {}

class SavingState extends LoadingState {}

class OpenState extends Equatable implements VaultState {
  final VaultData data;
  OpenState(this.data);

  @override
  List<Object?> get props => [data];
}

class ErrorState extends Equatable implements VaultState {
  final String message;
  ErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
