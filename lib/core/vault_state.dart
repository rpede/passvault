import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../models/credential.dart';
import 'failures.dart';

enum VaultStatus {
  open,
  closed,
  absent,
  opening,
  saving,
}

class VaultState extends Equatable {
  final IList<Credential> credentials;
  final VaultStatus status;
  final Failure? failure;

  const VaultState({
    required this.credentials,
    required this.status,
    this.failure,
  });

  VaultState.initial(bool exists)
      : credentials = <Credential>[].lock,
        status = exists ? VaultStatus.closed : VaultStatus.absent,
        failure = null;

  VaultState failed({VaultStatus? status, required Failure reason}) {
    return copyWith(status: status, failure: reason);
  }

  VaultState ok({
    IList<Credential>? credentials,
    required VaultStatus status,
  }) {
    return copyWith(credentials: credentials, status: status, failure: null);
  }

  VaultState copyWith({
    IList<Credential>? credentials,
    VaultStatus? status,
    Failure? failure,
  }) {
    return VaultState(
      credentials: credentials ?? this.credentials,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [credentials, status];
}
