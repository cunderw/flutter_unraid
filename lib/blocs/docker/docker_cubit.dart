import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/docker/docker_state.dart';
import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class DockerCubit extends Cubit<DockerState> {
  static const _tag = 'DockerCubit';
  final DockerRepository _repository;
  DockerCubit(this._repository) : super(const DockerInitial());

  Future<void> load() async {
    emit(const DockerLoading());
    try {
      final containers = await _repository.getContainers();
      emit(DockerLoaded(containers));
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'loading containers',
        stackTrace: st,
      );
      Log.e('Failed to load containers', tag: _tag, error: e, stackTrace: st);
      emit(DockerError(error.message));
    }
  }

  Future<void> refresh() => load();

  Future<void> startContainer(String id) async {
    try {
      await _repository.startContainer(id);
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'starting container', id: id);
    }
  }

  Future<void> stopContainer(String id) async {
    try {
      await _repository.stopContainer(id);
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'stopping container', id: id);
    }
  }

  Future<void> restartContainer(String id) async {
    try {
      await _repository.restartContainer(id);
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'restarting container', id: id);
    }
  }

  Future<void> removeContainer(String id, {bool withImage = false}) async {
    try {
      await _repository.removeContainer(id, withImage: withImage);
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'removing container', id: id);
    }
  }

  void _emitActionError(
    Object e,
    StackTrace st,
    String operation, {
    String? id,
  }) {
    final error = AppException.from(e, operation: operation, stackTrace: st);
    final label = id != null ? '$operation $id' : operation;
    Log.e('Failed $label', tag: _tag, error: e, stackTrace: st);
    final current = state;
    if (current is DockerLoaded) {
      emit(
        DockerActionError(
          containers: current.containers,
          message: error.message,
        ),
      );
    } else if (current is DockerActionError) {
      emit(
        DockerActionError(
          containers: current.containers,
          message: error.message,
        ),
      );
    } else {
      emit(DockerError(error.message));
    }
  }
}
