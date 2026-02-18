import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/data/repositories/vm_repository.dart';
import 'package:flutter_unraid/ui/screens/vm_detail/cubit/vm_logs_state.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class VmLogsCubit extends Cubit<VmLogsState> {
  static const _tag = 'VmLogsCubit';
  final VmRepository _repository;
  final String vmId;

  VmLogsCubit(this._repository, {required this.vmId})
      : super(const VmLogsInitial());

  Future<void> load() async {
    emit(const VmLogsLoading());
    try {
      final lines = await _repository.getVmLogs(vmId);
      emit(VmLogsLoaded(lines));
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'loading VM logs',
        stackTrace: st,
      );
      Log.e(
        'Failed to load logs for $vmId',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      emit(VmLogsError(error.message));
    }
  }

  Future<void> refresh() => load();
}
