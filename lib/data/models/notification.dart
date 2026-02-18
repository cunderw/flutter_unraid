import 'package:equatable/equatable.dart';

enum NotificationSeverity {
  normal,
  warning,
  alert,
  unknown;

  factory NotificationSeverity.fromString(String value) {
    return NotificationSeverity.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => NotificationSeverity.unknown,
    );
  }
}

class Notification extends Equatable {
  final String id;
  final String subject;
  final String description;
  final NotificationSeverity severity;
  final String timestamp;
  final bool read;

  const Notification({
    required this.id,
    required this.subject,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.read,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      severity: NotificationSeverity.fromString(
        json['severity'] as String? ?? 'NORMAL',
      ),
      timestamp: json['timestamp'] as String? ?? '',
      read: json['read'] as bool? ?? false,
    );
  }

  bool get isUnread => !read;
  bool get isAlert => severity == NotificationSeverity.alert;
  bool get isWarning => severity == NotificationSeverity.warning;

  @override
  List<Object?> get props => [id, subject, description, severity, timestamp, read];
}
