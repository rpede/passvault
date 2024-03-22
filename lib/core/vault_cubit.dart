import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../infrastructure/protection.dart';
import '../models/open_vault.dart';
import '../models/credential.dart';
import 'failures.dart';
import 'vault_api.dart';
import 'vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  final VaultApi api;
  Key? _key;
  static const closeAfter = Duration(minutes: 1);
  Timer? _timer;

  VaultCubit(this.api) : super(VaultState.initial(api.exists));

  @override
  void onChange(Change<VaultState> change) {
    super.onChange(change);
    if (change.nextState.status == VaultStatus.open) {
      _timer?.cancel();
      _timer = Timer(closeAfter, closeVault);
    }
  }

  Future<void> createVault(String masterPassword) async {
    // If an vault is absent then allow creating one.
    // We shouldn't allow accidentally override all stored passwords.
    assert(state.status == VaultStatus.absent);

    // We start by emitting an "opening" state.
    // It can be used to show a spinner in UI.
    emit(state.ok(status: VaultStatus.opening));

    try {
      // Ask api to create a new vault that can be opened with the given master
      // password.
      final vault = await api.create(masterPassword);
      // The key shouldn't be accessible through the UI, so we store it in a
      // private instance variable.
      _key = vault.key;

      // Emit "open" state with credentials converted to IList (immutable list).
      emit(state.ok(
        credentials: vault.credentials.lock,
        status: VaultStatus.open,
      ));
    } catch (e) {
      // If something goes wrong we emit new "absent" state with a generic
      // failure.
      emit(state.failed(
        status: VaultStatus.absent,
        reason: UnknownVaultFailure(),
      ));
      // Forward details to `addError` so a BlocObserver can log it.
      addError(e);
    }
  }

  Future<void> openVault(String masterPassword) async {
    // It doesn't make sense to attempt to open a vault if it is absent.
    assert(state.status == VaultStatus.closed);

    // Emit "opening" so UI can show a spinner (or some other indicator).
    emit(state.ok(status: VaultStatus.opening));
    try {
      // Attempt to open the stored vault.
      // It will throw an exception if `masterPassword` is wrong.
      final vault = await api.open(masterPassword);

      // The key shouldn't be accessible through the UI, so we store it in a
      // private instance variable.
      _key = vault.key;

      // Emit "open" state with credentials converted to IList (immutable list).
      emit(state.ok(
        credentials: vault.credentials.lock,
        status: VaultStatus.open,
      ));
    } catch (e) {
      // If something goes wrong we emit new "absent" state with a specialized
      // failure message.
      emit(state.failed(
        status: VaultStatus.closed,
        reason: OpenVaultFailure(),
      ));
      // Forward details to `addError` so a BlocObserver can log it.
      addError(e);
    }
  }

  Future<void> addCredential(Credential credential) async {
    // Requires that the vault have opened.
    assert(state.status == VaultStatus.open);

    // Emit "saving" so UI can show an indication.
    emit(state.ok(status: VaultStatus.saving));
    try {
      // "unlock" (getting mutable copy) credentials.
      // Then add the new credential.
      final credentials = state.credentials.unlock..add(credential);

      // Save the new credentials immediately.
      await api.save(OpenVault(credentials: credentials, key: _key!));

      // "lock" (get immutable copy) credentials and emit it as a new "open"
      // state.
      emit(state.ok(
        credentials: credentials.lock,
        status: VaultStatus.open,
      ));
    } catch (e) {
      // Transition back to "open" state if something goes wrong.
      emit(state.failed(
        status: VaultStatus.open,
        reason: SaveVaultFailure(),
      ));
      addError(e);
    }
  }

  void closeVault() {
    // Destroy key.
    // User would have to open with same master-password to access credentials
    // again.
    _key?.destroy();
    // "closed" state with empty credentials.
    emit(state.ok(
      credentials: <Credential>[].lock,
      status: VaultStatus.closed,
    ));
  }

  void delete() {
    api.delete();
  }
}
