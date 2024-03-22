import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../infrastructure/protection.dart';
import '../models/open_vault.dart';
import '../models/credential.dart';
import 'vault_api.dart';
import 'vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  final VaultApi api;
  Key? _key;
  static const closeAfter = Duration(minutes: 1);
  Timer? _timer;

  VaultCubit(this.api) : super(api.exists ? ExistsState() : AbsentState());

  @override
  void onChange(Change<VaultState> change) {
    super.onChange(change);
    if (change.nextState is OpenState) {
      _timer?.cancel();
      _timer = Timer(closeAfter, closeVault);
    }
  }

  Future<void> createVault(String masterPassword) async {
    // If an vault is absent then allow creating one.
    // We shouldn't allow accidentally override all stored passwords.
    assert(state is AbsentState);

    // We start by emitting an "opening" state.
    // It can be used to show a spinner in UI.
    emit(OpeningState());

    try {
      // Ask api to create a new vault that can be opened with the given master
      // password.
      final vault = await api.create(masterPassword);
      // The key shouldn't be accessible through the UI, so we store it in a
      // private instance variable.
      _key = vault.key;

      // Emit "open" state with credentials converted to IList (immutable list).
      emit(OpenState(vault.credentials.lock));
    } catch (e) {
      // If something goes wrong we emit new "absent" state with a generic
      // failure.
      emit(FailedToCreateState());
      // Forward details to `addError` so a BlocObserver can log it.
      addError(e);
    }
  }

  Future<void> openVault(String masterPassword) async {
    // It doesn't make sense to attempt to open a vault if it is absent.
    assert(state is ClosedState);

    // Emit "opening" so UI can show a spinner (or some other indicator).
    emit(OpeningState());
    try {
      // Attempt to open the stored vault.
      // It will throw an exception if `masterPassword` is wrong.
      final vault = await api.open(masterPassword);

      // The key shouldn't be accessible through the UI, so we store it in a
      // private instance variable.
      _key = vault.key;

      // Emit "open" state with credentials converted to IList (immutable list).
      emit(OpenState(vault.credentials.lock));
    } catch (e) {
      // If something goes wrong we emit new "absent" state with a specialized
      // failure message.
      emit(FailedToOpenState());
      // Forward details to `addError` so a BlocObserver can log it.
      addError(e);
    }
  }

  Future<void> addCredential(Credential credential) async {
    // Requires that the vault have opened.
    if (state is! OpenState) return;
    final oldState = state as OpenState;

    // Emit "saving" so UI can show an indication.
    emit(SavingState());
    try {
      // "unlock" (getting mutable copy) credentials.
      // Then add the new credential.
      final credentials = oldState.credentials.unlock..add(credential);

      // Save the new credentials immediately.
      await api.save(OpenVault(credentials: credentials, key: _key!));

      // "lock" (get immutable copy) credentials and emit it as a new "open"
      // state.
      emit(OpenState(credentials.lock));
    } catch (e) {
      // Transition back to "open" state if something goes wrong.
      emit(FailedToSaveState(oldState.credentials));
      addError(e);
    }
  }

  void closeVault() {
    // Destroy key.
    // User would have to open with same master-password to access credentials
    // again.
    _key?.destroy();
    // "closed" state with empty credentials.
    emit(api.exists ? ExistsState() : AbsentState());
  }

  void delete() {
    api.delete();
  }
}
