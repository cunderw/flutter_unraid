import 'package:equatable/equatable.dart';

sealed class VmLogsState extends Equatable {
  const VmLogsState();

  @override
  List<Object?> get props => [];
}

final class VmLogsInitial extends VmLogsState {
  const VmLogsInitial();
}

final class VmLogsLoading extends VmLogsState {
  const VmLogsLoading();
}

final class VmLogsLoaded extends VmLogsState {
  final List<String> lines;

  const VmLogsLoaded(this.lines);

  @override
  List<Object?> get props => [lines];
}

final class VmLogsError extends VmLogsState {
  final String message;

  const VmLogsError(this.message);

  @override
  List<Object?> get props => [message];
}
