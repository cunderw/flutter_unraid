class Capacity {
  final String free;
  final String used;
  final String total;

  const Capacity({required this.free, required this.used, required this.total});

  factory Capacity.fromJson(Map<String, dynamic> json) => Capacity(
    free: json['free']?.toString() ?? '0',
    used: json['used']?.toString() ?? '0',
    total: json['total']?.toString() ?? '0',
  );
}

class ArrayCapacity {
  final Capacity? kilobytes;
  final Capacity? disks;

  const ArrayCapacity({this.kilobytes, this.disks});

  factory ArrayCapacity.fromJson(Map<String, dynamic> json) => ArrayCapacity(
    kilobytes: json['kilobytes'] != null
        ? Capacity.fromJson(json['kilobytes'] as Map<String, dynamic>)
        : null,
    disks: json['disks'] != null
        ? Capacity.fromJson(json['disks'] as Map<String, dynamic>)
        : null,
  );
}

class ArrayDisk {
  final String id;
  final String? name;
  final String? device;
  final num? size;
  final String? status;
  final int? temp;
  final num? fsFree;
  final num? fsUsed;
  final num? fsSize;
  final String? type;
  final String? color;
  final String? comment;
  final String? fsType;
  final num? numReads;
  final num? numWrites;
  final num? numErrors;

  const ArrayDisk({
    required this.id,
    this.name,
    this.device,
    this.size,
    this.status,
    this.temp,
    this.fsFree,
    this.fsUsed,
    this.fsSize,
    this.type,
    this.color,
    this.comment,
    this.fsType,
    this.numReads,
    this.numWrites,
    this.numErrors,
  });

  String get displayName => name ?? device ?? id;

  bool get isHealthy => status == 'DISK_OK';

  double get usagePercent {
    if (fsUsed == null || fsSize == null || fsSize == 0) return 0;
    return (fsUsed! / fsSize!).clamp(0.0, 1.0);
  }

  factory ArrayDisk.fromJson(Map<String, dynamic> json) => ArrayDisk(
    id: json['id'] as String,
    name: json['name'] as String?,
    device: json['device'] as String?,
    size: json['size'] as num?,
    status: json['status'] as String?,
    temp: json['temp'] as int?,
    fsFree: json['fsFree'] as num?,
    fsUsed: json['fsUsed'] as num?,
    fsSize: json['fsSize'] as num?,
    type: json['type'] as String?,
    color: json['color'] as String?,
    comment: json['comment'] as String?,
    fsType: json['fsType'] as String?,
    numReads: json['numReads'] as num?,
    numWrites: json['numWrites'] as num?,
    numErrors: json['numErrors'] as num?,
  );
}

class ArrayData {
  final String state;
  final ArrayCapacity? capacity;
  final List<ArrayDisk> disks;
  final List<ArrayDisk> parities;
  final List<ArrayDisk> caches;

  const ArrayData({
    required this.state,
    this.capacity,
    this.disks = const [],
    this.parities = const [],
    this.caches = const [],
  });

  bool get isStarted => state == 'STARTED';

  int get totalDisks => disks.length + parities.length + caches.length;

  factory ArrayData.fromJson(Map<String, dynamic> json) => ArrayData(
    state: json['state'] as String? ?? 'UNKNOWN',
    capacity: json['capacity'] != null
        ? ArrayCapacity.fromJson(json['capacity'] as Map<String, dynamic>)
        : null,
    disks:
        (json['disks'] as List<dynamic>?)
            ?.map((e) => ArrayDisk.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    parities:
        (json['parities'] as List<dynamic>?)
            ?.map((e) => ArrayDisk.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    caches:
        (json['caches'] as List<dynamic>?)
            ?.map((e) => ArrayDisk.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
