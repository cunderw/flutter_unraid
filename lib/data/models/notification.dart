import 'package:equatable/equatable.dart';

enum NotificationImportance {
  info,
  warning,
  alert,
  unknown;

  factory NotificationImportance.fromString(String value) {
    return NotificationImportance.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => NotificationImportance.unknown,
    );
  }
}

enum NotificationType {
  unread,
  archive,
  unknown;

  factory NotificationType.fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => NotificationType.unknown,
    );
  }
}

class Notification extends Equatable {
  final String id;
  final String title;
  final String subject;
  final String description;
  final NotificationImportance importance;
  final String? link;
  final NotificationType type;
  final String timestamp;
  final String formattedTimestamp;

  const Notification({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.importance,
    this.link,
    required this.type,
    required this.timestamp,
    required this.formattedTimestamp,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      importance: NotificationImportance.fromString(
        json['importance'] as String? ?? 'INFO',
      ),
      link: json['link'] as String?,
      type: NotificationType.fromString(json['type'] as String? ?? 'UNREAD'),
      timestamp: json['timestamp'] as String? ?? '',
      formattedTimestamp: json['formattedTimestamp'] as String? ?? '',
    );
  }

  bool get isUnread => type == NotificationType.unread;
  bool get isArchived => type == NotificationType.archive;
  bool get isAlert => importance == NotificationImportance.alert;
  bool get isWarning => importance == NotificationImportance.warning;

  @override
  List<Object?> get props => [
    id,
    title,
    subject,
    description,
    importance,
    link,
    type,
    timestamp,
    formattedTimestamp,
  ];
}
