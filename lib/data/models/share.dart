class Share {
  final String id;
  final String? name;
  final num? free;
  final num? used;
  final num? size;
  final String? comment;
  final bool? cache;
  final List<String>? include;
  final List<String>? exclude;
  final String? allocator;
  final String? splitLevel;
  final String? floor;
  final String? cow;
  final String? color;
  final String? luksStatus;

  const Share({
    required this.id,
    this.name,
    this.free,
    this.used,
    this.size,
    this.comment,
    this.cache,
    this.include,
    this.exclude,
    this.allocator,
    this.splitLevel,
    this.floor,
    this.cow,
    this.color,
    this.luksStatus,
  });

  String get displayName => name ?? id;

  double get usagePercent {
    if (used == null || size == null || size == 0) return 0;
    return (used! / size!).clamp(0.0, 1.0);
  }

  factory Share.fromJson(Map<String, dynamic> json) => Share(
    id: json['id'] as String,
    name: json['name'] as String?,
    free: json['free'] as num?,
    used: json['used'] as num?,
    size: json['size'] as num?,
    comment: json['comment'] as String?,
    cache: json['cache'] as bool?,
    include: (json['include'] as List<dynamic>?)?.cast<String>(),
    exclude: (json['exclude'] as List<dynamic>?)?.cast<String>(),
    allocator: json['allocator'] as String?,
    splitLevel: json['splitLevel'] as String?,
    floor: json['floor'] as String?,
    cow: json['cow'] as String?,
    color: json['color'] as String?,
    luksStatus: json['luksStatus'] as String?,
  );
}
