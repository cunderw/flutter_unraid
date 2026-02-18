import 'package:equatable/equatable.dart';

sealed class ContainerLogsState extends Equatable {
  const ContainerLogsState();

  @override
  List<Object?> get props => [];
}

final class ContainerLogsInitial extends ContainerLogsState {
  const ContainerLogsInitial();
}

final class ContainerLogsLoading extends ContainerLogsState {
  const ContainerLogsLoading();
}

final class ContainerLogsLoaded extends ContainerLogsState {
  final List<Map<String, dynamic>> lines;

  const ContainerLogsLoaded(this.lines);

  @override
  List<Object?> get props => [lines];
}

final class ContainerLogsError extends ContainerLogsState {
  final String message;

  const ContainerLogsError(this.message);

  @override
  List<Object?> get props => [message];
}
