import 'package:equatable/equatable.dart';

sealed class SystemLogsState extends Equatable {
  const SystemLogsState();

  @override
  List<Object?> get props => [];
}

final class SystemLogsInitial extends SystemLogsState {
  const SystemLogsInitial();
}

final class SystemLogsLoading extends SystemLogsState {
  const SystemLogsLoading();
}

final class SystemLogsLoaded extends SystemLogsState {
  final List<Map<String, dynamic>> lines;

  const SystemLogsLoaded(this.lines);

  @override
  List<Object?> get props => [lines];
}

final class SystemLogsError extends SystemLogsState {
  final String message;

  const SystemLogsError(this.message);

  @override
  List<Object?> get props => [message];
}
