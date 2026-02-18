import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/notifications/notification_state.dart';
import 'package:flutter_unraid/data/repositories/notification_repository.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class NotificationCubit extends Cubit<NotificationState> {
  static const _tag = 'NotificationCubit';
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(const NotificationInitial());

  Future<void> load() async {
    emit(const NotificationLoading());
    try {
      final notifications = await _repository.getNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'loading notifications',
        stackTrace: st,
      );
      Log.e('Failed to load notifications', tag: _tag, error: e, stackTrace: st);
      emit(NotificationError(error.message));
    }
  }

  Future<void> refresh() => load();

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'marking notification as read', id: id);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'marking all notifications as read');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'deleting notification', id: id);
    }
  }

  Future<void> deleteAll() async {
    try {
      await _repository.deleteAll();
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'deleting all notifications');
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
    if (current is NotificationLoaded) {
      emit(
        NotificationActionError(
          notifications: current.notifications,
          message: error.message,
        ),
      );
    } else if (current is NotificationActionError) {
      emit(
        NotificationActionError(
          notifications: current.notifications,
          message: error.message,
        ),
      );
    } else {
      emit(NotificationError(error.message));
    }
  }
}
