import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../models/credential.dart';

abstract class VaultState {}

abstract class FailedState {}

abstract class ClosedState implements VaultState {}

class AbsentState implements ClosedState {}

class ExistsState implements ClosedState {}

class FailedToCreateState implements AbsentState, FailedState {}

class OpeningState extends VaultState {}

class FailedToOpenState implements ExistsState, FailedState {}

class SavingState extends VaultState {}

class FailedToSaveState extends OpenState implements FailedState {
  FailedToSaveState(super.credentials);
}

class OpenState extends Equatable implements VaultState {
  final IList<Credential> credentials;

  OpenState(this.credentials);

  @override
  List<Object?> get props => [credentials];
}

class ErrorState extends Equatable implements VaultState {
  final String message;
  const ErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
