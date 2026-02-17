import 'package:equatable/equatable.dart';

import 'package:flutter_unraid/data/models/vm_domain.dart';

sealed class VmState extends Equatable {
  const VmState();

  @override
  List<Object?> get props => [];
}

final class VmInitial extends VmState {
  const VmInitial();
}

final class VmLoading extends VmState {
  const VmLoading();
}

final class VmLoaded extends VmState {
  final List<VmDomain> vms;

  const VmLoaded(this.vms);

  int get running => vms.where((v) => v.isRunning).length;
  int get stopped => vms.where((v) => v.isStopped).length;

  @override
  List<Object?> get props => [vms];
}

final class VmError extends VmState {
  final String message;

  const VmError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when an action (start/stop/etc.) fails but the loaded data
/// should remain visible. The UI should show a snackbar instead of
/// replacing the view.
final class VmActionError extends VmState {
  final List<VmDomain> vms;
  final String message;

  const VmActionError({required this.vms, required this.message});

  int get running => vms.where((v) => v.isRunning).length;

  @override
  List<Object?> get props => [vms, message];
}
