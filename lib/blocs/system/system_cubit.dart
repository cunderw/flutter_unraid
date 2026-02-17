import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/system/system_state.dart';
import 'package:flutter_unraid/data/models/array_data.dart';
import 'package:flutter_unraid/data/models/system_info.dart';
import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class SystemCubit extends Cubit<SystemState> {
  static const _tag = 'SystemCubit';
  final SystemRepository _repository;

  SystemCubit(this._repository) : super(const SystemInitial());

  Future<void> load() async {
    emit(const SystemLoading());
    try {
      final results = await Future.wait([
        _repository.getSystemInfo(),
        _repository.getArrayData(),
      ]);
      final sysResult =
          results[0] as ({SystemInfo systemInfo, MemoryUtilization? memory});
      emit(
        SystemLoaded(
          systemInfo: sysResult.systemInfo,
          memory: sysResult.memory,
          arrayData: results[1] as ArrayData,
        ),
      );
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'loading system data',
        stackTrace: st,
      );
      Log.e('Failed to load system data', tag: _tag, error: e, stackTrace: st);
      emit(SystemError(error.message));
    }
  }

  Future<void> refresh() => load();

  Future<void> setArrayState(String desiredState) async {
    try {
      await _repository.setArrayState(desiredState);
      await load();
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'setting array state',
        stackTrace: st,
      );
      Log.e('Failed to set array state', tag: _tag, error: e, stackTrace: st);
      emit(SystemError(error.message));
    }
  }
}
