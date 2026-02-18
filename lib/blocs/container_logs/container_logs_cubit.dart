import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/container_logs/container_logs_state.dart';
import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class ContainerLogsCubit extends Cubit<ContainerLogsState> {
  static const _tag = 'ContainerLogsCubit';
  final DockerRepository _repository;
  final String containerId;

  ContainerLogsCubit(this._repository, {required this.containerId})
    : super(const ContainerLogsInitial());

  Future<void> load() async {
    emit(const ContainerLogsLoading());
    try {
      final lines = await _repository.getContainerLogs(containerId);
      emit(ContainerLogsLoaded(lines));
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'loading container logs',
        stackTrace: st,
      );
      Log.e(
        'Failed to load logs for $containerId',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      emit(ContainerLogsError(error.message));
    }
  }

  Future<void> refresh() => load();
}
