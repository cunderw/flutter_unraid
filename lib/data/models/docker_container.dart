import 'package:equatable/equatable.dart';

class ContainerPort extends Equatable {
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

  @override
  List<Object?> get props => [ip, privatePort, publicPort, type];
}

class ContainerMount extends Equatable {
  final String source;
  final String destination;
  final String type;
  final String mode;

  const ContainerMount({
    required this.source,
    required this.destination,
    required this.type,
    this.mode = 'rw',
  });

  bool get isReadOnly => mode.toLowerCase() == 'ro';

  factory ContainerMount.fromJson(Map<String, dynamic> json) => ContainerMount(
    source: json['source'] as String? ?? '',
    destination: json['destination'] as String? ?? '',
    type: json['type'] as String? ?? 'bind',
    mode: json['mode'] as String? ?? 'rw',
  );

  @override
  List<Object?> get props => [source, destination, type, mode];
}

class DockerContainer extends Equatable {
  final String id;
  final List<String> names;
  final String image;
  final String imageId;
  final String state;
  final String status;
  final bool autoStart;
  final List<ContainerPort> ports;
  final List<ContainerMount> mounts;
  final String? iconUrl;
  final String? webUiUrl;
  final String? templatePath;
  final String? projectUrl;
  final String? supportUrl;
  final String? registryUrl;

  const DockerContainer({
    required this.id,
    required this.names,
    required this.image,
    this.imageId = '',
    required this.state,
    required this.status,
    required this.autoStart,
    this.ports = const [],
    this.mounts = const [],
    this.iconUrl,
    this.webUiUrl,
    this.templatePath,
    this.projectUrl,
    this.supportUrl,
    this.registryUrl,
  });

  String get displayName =>
      names.isNotEmpty ? names.first.replaceAll(RegExp(r'^/'), '') : 'Unknown';

  bool get isRunning => state == 'RUNNING';
  bool get isPaused => state == 'PAUSED';
  bool get isStopped => state == 'EXITED';
  bool get hasMounts => mounts.isNotEmpty;
  bool get hasLinks =>
      projectUrl != null || supportUrl != null || registryUrl != null;

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
        mounts:
            (json['mounts'] as List<dynamic>?)
                ?.map((e) => ContainerMount.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        iconUrl: json['iconUrl'] as String?,
        webUiUrl: json['webUiUrl'] as String?,
        templatePath: json['templatePath'] as String?,
        projectUrl: json['projectUrl'] as String?,
        supportUrl: json['supportUrl'] as String?,
        registryUrl: json['registryUrl'] as String?,
      );

  @override
  List<Object?> get props => [
    id,
    names,
    image,
    imageId,
    state,
    status,
    autoStart,
    ports,
    mounts,
    iconUrl,
    webUiUrl,
    templatePath,
    projectUrl,
    supportUrl,
    registryUrl,
  ];
}
