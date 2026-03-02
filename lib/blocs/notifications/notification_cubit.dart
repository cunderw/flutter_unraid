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
      Log.e(
        'Failed to load notifications',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      emit(NotificationError(error.message));
    }
  }

  Future<void> refresh() => load();

  Future<void> archiveNotification(String id) async {
    try {
      Log.i('Archiving notification $id', tag: _tag);
      await _repository.archiveNotification(id);
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'archiving notification', id: id);
    }
  }

  Future<void> archiveAllNotifications() async {
    final current = state;
    try {
      Log.i('Archiving all notifications', tag: _tag);
      if (current is NotificationLoaded) {
        final ids = current.notifications.map((n) => n.id).toList();
        await _repository.archiveAllNotifications(ids);
      }
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'archiving all notifications');
    }
  }

  Future<void> unreadNotification(String id) async {
    try {
      Log.i('Marking notification $id as unread', tag: _tag);
      await _repository.unreadNotification(id);
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'marking notification as unread', id: id);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      Log.i('Deleting notification $id', tag: _tag);
      await _repository.deleteNotification(id);
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'deleting notification', id: id);
    }
  }

  Future<void> deleteArchivedNotifications() async {
    try {
      Log.i('Deleting all archived notifications', tag: _tag);
      await _repository.deleteArchivedNotifications();
      await load();
    } catch (e, st) {
      _emitActionError(e, st, 'deleting archived notifications');
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
