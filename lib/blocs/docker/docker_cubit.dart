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
      final error = AppException.from(
        e,
        operation: 'starting container',
        stackTrace: st,
      );
      Log.e(
        'Failed to start container $id',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      emit(DockerError(error.message));
    }
  }

  Future<void> stopContainer(String id) async {
    try {
      await _repository.stopContainer(id);
      await load();
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'stopping container',
        stackTrace: st,
      );
      Log.e(
        'Failed to stop container $id',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      emit(DockerError(error.message));
    }
  }

  Future<void> pauseContainer(String id) async {
    try {
      await _repository.pauseContainer(id);
      await load();
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'pausing container',
        stackTrace: st,
      );
      Log.e(
        'Failed to pause container $id',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      emit(DockerError(error.message));
    }
  }

  Future<void> unpauseContainer(String id) async {
    try {
      await _repository.unpauseContainer(id);
      await load();
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'unpausing container',
        stackTrace: st,
      );
      Log.e(
        'Failed to unpause container $id',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      emit(DockerError(error.message));
    }
  }

  Future<void> removeContainer(String id, {bool withImage = false}) async {
    try {
      await _repository.removeContainer(id, withImage: withImage);
      await load();
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'removing container',
        stackTrace: st,
      );
      Log.e(
        'Failed to remove container $id',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      emit(DockerError(error.message));
    }
  }
}
