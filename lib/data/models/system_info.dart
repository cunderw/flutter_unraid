class OsInfo {
  final String? platform;
  final String? distro;
  final String? release;
  final String? uptime;

  const OsInfo({this.platform, this.distro, this.release, this.uptime});

  factory OsInfo.fromJson(Map<String, dynamic> json) => OsInfo(
    platform: json['platform'] as String?,
    distro: json['distro'] as String?,
    release: json['release'] as String?,
    uptime: json['uptime'] as String?,
  );
}

class CpuInfo {
  final String? manufacturer;
  final String? brand;
  final int? cores;
  final int? threads;

  const CpuInfo({this.manufacturer, this.brand, this.cores, this.threads});

  factory CpuInfo.fromJson(Map<String, dynamic> json) => CpuInfo(
    manufacturer: json['manufacturer'] as String?,
    brand: json['brand'] as String?,
    cores: json['cores'] as int?,
    threads: json['threads'] as int?,
  );
}

class MemoryUtilization {
  final num? total;
  final num? free;
  final num? used;
  final num? active;
  final num? available;
  final double? percentTotal;

  const MemoryUtilization({
    this.total,
    this.free,
    this.used,
    this.active,
    this.available,
    this.percentTotal,
  });

  factory MemoryUtilization.fromJson(Map<String, dynamic> json) =>
      MemoryUtilization(
        total: json['total'] as num?,
        free: json['free'] as num?,
        used: json['used'] as num?,
        active: json['active'] as num?,
        available: json['available'] as num?,
        percentTotal: (json['percentTotal'] as num?)?.toDouble(),
      );
}

class SystemInfo {
  final OsInfo? os;
  final CpuInfo? cpu;

  const SystemInfo({this.os, this.cpu});

  factory SystemInfo.fromJson(Map<String, dynamic> json) => SystemInfo(
    os: json['os'] != null
        ? OsInfo.fromJson(json['os'] as Map<String, dynamic>)
        : null,
    cpu: json['cpu'] != null
        ? CpuInfo.fromJson(json['cpu'] as Map<String, dynamic>)
        : null,
  );
}
