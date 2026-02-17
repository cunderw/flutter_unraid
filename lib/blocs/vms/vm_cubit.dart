import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/vms/vm_state.dart';
import 'package:flutter_unraid/data/repositories/vm_repository.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class VmCubit extends Cubit<VmState> {
  static const _tag = 'VmCubit';
  final VmRepository _repository;

  VmCubit(this._repository) : super(const VmInitial());

  Future<void> load() async {
    emit(const VmLoading());
    try {
      final vms = await _repository.getVms();
      emit(VmLoaded(vms));
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'loading VMs',
        stackTrace: st,
      );
      Log.e('Failed to load VMs', tag: _tag, error: e, stackTrace: st);
      emit(VmError(error.message));
    }
  }

  Future<void> refresh() => load();

  Future<void> _performAction(
    String id,
    String action,
    Future<void> Function(String) fn,
  ) async {
    try {
      await fn(id);
      await load();
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: '$action VM',
        stackTrace: st,
      );
      Log.e('Failed to $action VM $id', tag: _tag, error: e, stackTrace: st);
      emit(VmError(error.message));
    }
  }

  Future<void> startVm(String id) =>
      _performAction(id, 'start', _repository.startVm);

  Future<void> stopVm(String id) =>
      _performAction(id, 'stop', _repository.stopVm);

  Future<void> forceStopVm(String id) =>
      _performAction(id, 'force stop', _repository.forceStopVm);

  Future<void> pauseVm(String id) =>
      _performAction(id, 'pause', _repository.pauseVm);

  Future<void> resumeVm(String id) =>
      _performAction(id, 'resume', _repository.resumeVm);

  Future<void> rebootVm(String id) =>
      _performAction(id, 'reboot', _repository.rebootVm);
}
