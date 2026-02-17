class ContainerPort {
  final String? ip;
  final int? privatePort;
  final int? publicPort;
  final String type;

  const ContainerPort({
    this.ip,
    this.privatePort,
    this.publicPort,
    required this.type,
  });

  String get displayString {
    final pub = publicPort != null ? '$publicPort:' : '';
    final priv = privatePort?.toString() ?? '';
    return '$pub$priv/${type.toLowerCase()}';
  }

  factory ContainerPort.fromJson(Map<String, dynamic> json) => ContainerPort(
    ip: json['ip'] as String?,
    privatePort: json['privatePort'] as int?,
    publicPort: json['publicPort'] as int?,
    type: json['type'] as String? ?? 'TCP',
  );
}

class DockerContainer {
  final String id;
  final List<String> names;
  final String image;
  final String imageId;
  final String state;
  final String status;
  final bool autoStart;
  final List<ContainerPort> ports;
  final String? iconUrl;
  final String? webUiUrl;
  final String? templatePath;

  const DockerContainer({
    required this.id,
    required this.names,
    required this.image,
    this.imageId = '',
    required this.state,
    required this.status,
    required this.autoStart,
    this.ports = const [],
    this.iconUrl,
    this.webUiUrl,
    this.templatePath,
  });

  String get displayName =>
      names.isNotEmpty ? names.first.replaceAll(RegExp(r'^/'), '') : 'Unknown';

  bool get isRunning => state == 'RUNNING';
  bool get isPaused => state == 'PAUSED';
  bool get isStopped => state == 'EXITED';

  factory DockerContainer.fromJson(Map<String, dynamic> json) =>
      DockerContainer(
        id: json['id'] as String,
        names: (json['names'] as List<dynamic>?)?.cast<String>() ?? [],
        image: json['image'] as String? ?? '',
        imageId: json['imageId'] as String? ?? '',
        state: json['state'] as String? ?? 'UNKNOWN',
        status: json['status'] as String? ?? '',
        autoStart: json['autoStart'] as bool? ?? false,
        ports:
            (json['ports'] as List<dynamic>?)
                ?.map((e) => ContainerPort.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        iconUrl: json['iconUrl'] as String?,
        webUiUrl: json['webUiUrl'] as String?,
        templatePath: json['templatePath'] as String?,
      );
}
