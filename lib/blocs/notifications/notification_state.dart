import 'package:equatable/equatable.dart';

import 'package:flutter_unraid/data/models/notification.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;

  const NotificationLoaded(this.notifications);

  int get totalCount => notifications.length;
  int get alertCount => notifications.where((n) => n.isAlert).length;
  int get warningCount => notifications.where((n) => n.isWarning).length;

  @override
  List<Object?> get props => [notifications];
}

final class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when an action (mark as read/delete) fails but the loaded data
/// should remain visible. The UI should show a snackbar instead of
/// replacing the view.
final class NotificationActionError extends NotificationState {
  final List<Notification> notifications;
  final String message;

  const NotificationActionError({
    required this.notifications,
    required this.message,
  });

  int get totalCount => notifications.length;

  @override
  List<Object?> get props => [notifications, message];
}
