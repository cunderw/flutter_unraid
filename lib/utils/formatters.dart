import 'dart:math';

class Formatters {
  Formatters._();

  /// Formats raw bytes into a human-readable string (e.g. "1.5 GB").
  static String formatBytes(num? bytes, {int decimals = 1}) {
    if (bytes == null || bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    final i = (bytes > 0 ? (log(bytes) / log(1024)).floor() : 0).clamp(
      0,
      suffixes.length - 1,
    );
    final value = bytes / pow(1024, i);
    return '${value.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Formats kilobytes into a human-readable string.
  static String formatKilobytes(num? kb, {int decimals = 1}) {
    if (kb == null) return '0 KB';
    return formatBytes(kb * 1024, decimals: decimals);
  }

  /// Formats an ISO boot-time string into a human-readable uptime
  /// (e.g. "5d 3h 12m").
  static String formatUptime(String? bootTime) {
    if (bootTime == null || bootTime.isEmpty) return 'Unknown';
    final boot = DateTime.tryParse(bootTime);
    if (boot == null) return 'Unknown';
    final duration = DateTime.now().difference(boot);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  /// Formats a temperature value with °C suffix.
  static String formatTemperature(int? temp) {
    if (temp == null) return '--';
    return '$temp°C';
  }

  /// Computes a usage percentage (0.0 to 1.0) from used/total values.
  static double usagePercent(num? used, num? total) {
    if (used == null || total == null || total == 0) return 0;
    return (used / total).clamp(0.0, 1.0);
  }

  /// Formats a container state string for display.
  static String formatState(String state) {
    return state
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
