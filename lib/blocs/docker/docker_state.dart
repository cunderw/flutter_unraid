import 'package:equatable/equatable.dart';

import 'package:flutter_unraid/data/models/docker_container.dart';

sealed class DockerState extends Equatable {
  const DockerState();

  @override
  List<Object?> get props => [];
}

final class DockerInitial extends DockerState {
  const DockerInitial();
}

final class DockerLoading extends DockerState {
  const DockerLoading();
}

final class DockerLoaded extends DockerState {
  final List<DockerContainer> containers;

  const DockerLoaded(this.containers);

  int get running => containers.where((c) => c.isRunning).length;
  int get stopped => containers.where((c) => c.isStopped).length;

  @override
  List<Object?> get props => [containers];
}

final class DockerError extends DockerState {
  final String message;

  const DockerError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when an action (start/stop/etc.) fails but the loaded data
/// should remain visible. The UI should show a snackbar instead of
/// replacing the view.
final class DockerActionError extends DockerState {
  final List<DockerContainer> containers;
  final String message;

  const DockerActionError({required this.containers, required this.message});

  int get running => containers.where((c) => c.isRunning).length;

  @override
  List<Object?> get props => [containers, message];
}
