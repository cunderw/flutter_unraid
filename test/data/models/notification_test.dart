import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/data/models/notification.dart';

void main() {
  group('NotificationSeverity', () {
    test('fromString returns correct severity', () {
      expect(
        NotificationSeverity.fromString('NORMAL'),
        NotificationSeverity.normal,
      );
      expect(
        NotificationSeverity.fromString('WARNING'),
        NotificationSeverity.warning,
      );
      expect(
        NotificationSeverity.fromString('ALERT'),
        NotificationSeverity.alert,
      );
    });

    test('fromString is case-insensitive', () {
      expect(
        NotificationSeverity.fromString('normal'),
        NotificationSeverity.normal,
      );
      expect(
        NotificationSeverity.fromString('Alert'),
        NotificationSeverity.alert,
      );
    });

    test('fromString returns unknown for invalid value', () {
      expect(
        NotificationSeverity.fromString('INVALID'),
        NotificationSeverity.unknown,
      );
    });
  });

  group('Notification', () {
    test('fromJson parses valid JSON', () {
      final json = {
        'id': 'notif-1',
        'subject': 'Test Subject',
        'description': 'Test Description',
        'severity': 'ALERT',
        'timestamp': '2025-01-01T00:00:00Z',
        'read': true,
      };

      final notification = Notification.fromJson(json);

      expect(notification.id, 'notif-1');
      expect(notification.subject, 'Test Subject');
      expect(notification.description, 'Test Description');
      expect(notification.severity, NotificationSeverity.alert);
      expect(notification.timestamp, '2025-01-01T00:00:00Z');
      expect(notification.read, true);
    });

    test('fromJson handles null values with defaults', () {
      final json = {
        'id': 'notif-1',
      };

      final notification = Notification.fromJson(json);

      expect(notification.id, 'notif-1');
      expect(notification.subject, '');
      expect(notification.description, '');
      expect(notification.severity, NotificationSeverity.normal);
      expect(notification.timestamp, '');
      expect(notification.read, false);
    });

    test('isUnread returns correct value', () {
      final unread = Notification.fromJson({'id': '1', 'read': false});
      final read = Notification.fromJson({'id': '2', 'read': true});

      expect(unread.isUnread, true);
      expect(read.isUnread, false);
    });

    test('isAlert returns correct value', () {
      final alert = Notification.fromJson({'id': '1', 'severity': 'ALERT'});
      final normal = Notification.fromJson({'id': '2', 'severity': 'NORMAL'});

      expect(alert.isAlert, true);
      expect(normal.isAlert, false);
    });

    test('isWarning returns correct value', () {
      final warning = Notification.fromJson({'id': '1', 'severity': 'WARNING'});
      final normal = Notification.fromJson({'id': '2', 'severity': 'NORMAL'});

      expect(warning.isWarning, true);
      expect(normal.isWarning, false);
    });

    test('Equatable props includes all fields', () {
      final notif1 = Notification.fromJson({
        'id': '1',
        'subject': 'Test',
        'description': 'Desc',
        'severity': 'NORMAL',
        'timestamp': '2025-01-01T00:00:00Z',
        'read': false,
      });

      final notif2 = Notification.fromJson({
        'id': '1',
        'subject': 'Test',
        'description': 'Desc',
        'severity': 'NORMAL',
        'timestamp': '2025-01-01T00:00:00Z',
        'read': false,
      });

      final notif3 = Notification.fromJson({
        'id': '2',
        'subject': 'Test',
        'description': 'Desc',
        'severity': 'NORMAL',
        'timestamp': '2025-01-01T00:00:00Z',
        'read': false,
      });

      expect(notif1, notif2);
      expect(notif1, isNot(notif3));
    });
  });
}
