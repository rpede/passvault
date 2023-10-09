import 'package:equatable/equatable.dart';
import 'package:cryptography/cryptography.dart';

import 'vault_data.dart';

class VaultState {}

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

class OpenState extends VaultState {
  final SecretKey key;
  final List<VaultItem> data;
  OpenState(this.key, this.data);
}
