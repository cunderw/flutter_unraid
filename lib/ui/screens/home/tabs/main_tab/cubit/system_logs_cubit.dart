import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/cubit/system_logs_state.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class SystemLogsCubit extends Cubit<SystemLogsState> {
  static const _tag = 'SystemLogsCubit';
  final SystemRepository _repository;

  SystemLogsCubit(this._repository) : super(const SystemLogsInitial());

  Future<void> load({int? lines}) async {
    emit(const SystemLogsLoading());
    try {
      final logLines = await _repository.getSystemLogs(lines: lines);
      emit(SystemLogsLoaded(logLines));
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'loading system logs',
        stackTrace: st,
      );
      Log.e('Failed to load system logs', tag: _tag, error: e, stackTrace: st);
      emit(SystemLogsError(error.message));
    }
  }

  Future<void> refresh({int? lines}) => load(lines: lines);
}
