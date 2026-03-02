import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/data/models/notification.dart';

void main() {
  group('NotificationImportance', () {
    test('fromString returns correct importance', () {
      expect(
        NotificationImportance.fromString('INFO'),
        NotificationImportance.info,
      );
      expect(
        NotificationImportance.fromString('WARNING'),
        NotificationImportance.warning,
      );
      expect(
        NotificationImportance.fromString('ALERT'),
        NotificationImportance.alert,
      );
    });

    test('fromString is case-insensitive', () {
      expect(
        NotificationImportance.fromString('info'),
        NotificationImportance.info,
      );
      expect(
        NotificationImportance.fromString('Alert'),
        NotificationImportance.alert,
      );
    });

    test('fromString returns unknown for invalid value', () {
      expect(
        NotificationImportance.fromString('INVALID'),
        NotificationImportance.unknown,
      );
    });
  });

  group('NotificationType', () {
    test('fromString returns correct type', () {
      expect(NotificationType.fromString('UNREAD'), NotificationType.unread);
      expect(NotificationType.fromString('ARCHIVE'), NotificationType.archive);
    });

    test('fromString is case-insensitive', () {
      expect(NotificationType.fromString('unread'), NotificationType.unread);
      expect(NotificationType.fromString('Archive'), NotificationType.archive);
    });

    test('fromString returns unknown for invalid value', () {
      expect(NotificationType.fromString('INVALID'), NotificationType.unknown);
    });
  });

  group('Notification', () {
    test('fromJson parses valid JSON', () {
      final json = {
        'id': 'notif-1',
        'title': 'Test Title',
        'subject': 'Test Subject',
        'description': 'Test Description',
        'importance': 'ALERT',
        'link': 'https://example.com',
        'type': 'UNREAD',
        'timestamp': '2025-01-01T00:00:00Z',
        'formattedTimestamp': 'Jan 1, 2025',
      };

      final notification = Notification.fromJson(json);

      expect(notification.id, 'notif-1');
      expect(notification.title, 'Test Title');
      expect(notification.subject, 'Test Subject');
      expect(notification.description, 'Test Description');
      expect(notification.importance, NotificationImportance.alert);
      expect(notification.link, 'https://example.com');
      expect(notification.type, NotificationType.unread);
      expect(notification.timestamp, '2025-01-01T00:00:00Z');
      expect(notification.formattedTimestamp, 'Jan 1, 2025');
    });

    test('fromJson handles null values with defaults', () {
      final json = {'id': 'notif-1'};

      final notification = Notification.fromJson(json);

      expect(notification.id, 'notif-1');
      expect(notification.title, '');
      expect(notification.subject, '');
      expect(notification.description, '');
      expect(notification.importance, NotificationImportance.info);
      expect(notification.link, isNull);
      expect(notification.type, NotificationType.unread);
      expect(notification.timestamp, '');
      expect(notification.formattedTimestamp, '');
    });

    test('isUnread returns correct value', () {
      final unread = Notification.fromJson({'id': '1', 'type': 'UNREAD'});
      final archived = Notification.fromJson({'id': '2', 'type': 'ARCHIVE'});

      expect(unread.isUnread, true);
      expect(archived.isUnread, false);
    });

    test('isArchived returns correct value', () {
      final archived = Notification.fromJson({'id': '1', 'type': 'ARCHIVE'});
      final unread = Notification.fromJson({'id': '2', 'type': 'UNREAD'});

      expect(archived.isArchived, true);
      expect(unread.isArchived, false);
    });

    test('isAlert returns correct value', () {
      final alert = Notification.fromJson({'id': '1', 'importance': 'ALERT'});
      final info = Notification.fromJson({'id': '2', 'importance': 'INFO'});

      expect(alert.isAlert, true);
      expect(info.isAlert, false);
    });

    test('isWarning returns correct value', () {
      final warning = Notification.fromJson({
        'id': '1',
        'importance': 'WARNING',
      });
      final info = Notification.fromJson({'id': '2', 'importance': 'INFO'});

      expect(warning.isWarning, true);
      expect(info.isWarning, false);
    });

    test('Equatable props includes all fields', () {
      final notif1 = Notification.fromJson({
        'id': '1',
        'title': 'Test',
        'subject': 'Sub',
        'description': 'Desc',
        'importance': 'INFO',
        'type': 'UNREAD',
        'timestamp': '2025-01-01T00:00:00Z',
        'formattedTimestamp': 'Jan 1, 2025',
      });

      final notif2 = Notification.fromJson({
        'id': '1',
        'title': 'Test',
        'subject': 'Sub',
        'description': 'Desc',
        'importance': 'INFO',
        'type': 'UNREAD',
        'timestamp': '2025-01-01T00:00:00Z',
        'formattedTimestamp': 'Jan 1, 2025',
      });

      final notif3 = Notification.fromJson({
        'id': '2',
        'title': 'Test',
        'subject': 'Sub',
        'description': 'Desc',
        'importance': 'INFO',
        'type': 'UNREAD',
        'timestamp': '2025-01-01T00:00:00Z',
        'formattedTimestamp': 'Jan 1, 2025',
      });

      expect(notif1, notif2);
      expect(notif1, isNot(notif3));
    });
  });
}
