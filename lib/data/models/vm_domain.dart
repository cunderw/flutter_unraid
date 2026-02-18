import 'package:equatable/equatable.dart';

class VmDomain extends Equatable {
  final String id;
  final String? name;
  final String state;
  final int? cpus;
  final int? memory;
  final bool? autostart;
  final String? template;
  final String? description;

  const VmDomain({
    required this.id,
    this.name,
    required this.state,
    this.cpus,
    this.memory,
    this.autostart,
    this.template,
    this.description,
  });

  String get displayName => name ?? id;

  bool get isRunning => state == 'RUNNING';
  bool get isPaused => state == 'PAUSED';
  bool get isStopped => state == 'SHUTOFF';
  bool get isCrashed => state == 'CRASHED';

  String get memoryDisplay {
    if (memory == null) return 'N/A';
    final mb = memory! / (1024 * 1024);
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(0)} MB';
  }

  factory VmDomain.fromJson(Map<String, dynamic> json) => VmDomain(
        id: json['id'] as String,
        name: json['name'] as String?,
        state: json['state'] as String? ?? 'NOSTATE',
        cpus: json['cpus'] as int?,
        memory: json['memory'] as int?,
        autostart: json['autostart'] as bool?,
        template: json['template'] as String?,
        description: json['description'] as String?,
      );

  @override
  List<Object?> get props =>
      [id, name, state, cpus, memory, autostart, template, description];
}
