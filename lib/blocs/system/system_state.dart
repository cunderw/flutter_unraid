import 'package:equatable/equatable.dart';

import 'package:flutter_unraid/data/models/array_data.dart';
import 'package:flutter_unraid/data/models/system_info.dart';

sealed class SystemState extends Equatable {
  const SystemState();

  @override
  List<Object?> get props => [];
}

final class SystemInitial extends SystemState {
  const SystemInitial();
}

final class SystemLoading extends SystemState {
  const SystemLoading();
}

final class SystemLoaded extends SystemState {
  final SystemInfo systemInfo;
  final MemoryUtilization? memory;
  final ArrayData arrayData;

  const SystemLoaded({
    required this.systemInfo,
    required this.arrayData,
    this.memory,
  });

  @override
  List<Object?> get props => [systemInfo, memory, arrayData];
}

final class SystemError extends SystemState {
  final String message;

  const SystemError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when an action (set array state, etc.) fails but the loaded data
/// should remain visible. The UI should show a snackbar instead of
/// replacing the view.
final class SystemActionError extends SystemState {
  final SystemInfo systemInfo;
  final MemoryUtilization? memory;
  final ArrayData arrayData;
  final String message;

  const SystemActionError({
    required this.systemInfo,
    required this.memory,
    required this.arrayData,
    required this.message,
  });

  @override
  List<Object?> get props => [systemInfo, memory, arrayData, message];
}
