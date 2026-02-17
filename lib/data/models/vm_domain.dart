class VmDomain {
  final String id;
  final String? name;
  final String state;

  const VmDomain({required this.id, this.name, required this.state});

  String get displayName => name ?? id;

  bool get isRunning => state == 'RUNNING';
  bool get isPaused => state == 'PAUSED';
  bool get isStopped => state == 'SHUTOFF';
  bool get isCrashed => state == 'CRASHED';

  factory VmDomain.fromJson(Map<String, dynamic> json) => VmDomain(
    id: json['id'] as String,
    name: json['name'] as String?,
    state: json['state'] as String? ?? 'NOSTATE',
  );
}
