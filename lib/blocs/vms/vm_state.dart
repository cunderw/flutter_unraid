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
