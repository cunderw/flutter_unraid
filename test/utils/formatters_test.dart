import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('formatBytes', () {
      test('formats 0 bytes', () {
        expect(Formatters.formatBytes(0), '0 B');
        expect(Formatters.formatBytes(null), '0 B');
      });

      test('formats bytes correctly', () {
        expect(Formatters.formatBytes(500), '500.0 B');
        expect(Formatters.formatBytes(1023), '1023.0 B');
      });

      test('formats kilobytes correctly', () {
        expect(Formatters.formatBytes(1024), '1.0 KB');
        expect(Formatters.formatBytes(1536), '1.5 KB');
        expect(Formatters.formatBytes(2048), '2.0 KB');
      });

      test('formats megabytes correctly', () {
        expect(Formatters.formatBytes(1048576), '1.0 MB');
        expect(Formatters.formatBytes(1572864), '1.5 MB');
      });

      test('formats gigabytes correctly', () {
        expect(Formatters.formatBytes(1073741824), '1.0 GB');
        expect(Formatters.formatBytes(1610612736), '1.5 GB');
      });

      test('formats terabytes correctly', () {
        expect(Formatters.formatBytes(1099511627776), '1.0 TB');
      });

      test('respects decimal parameter', () {
        expect(Formatters.formatBytes(1536, decimals: 0), '2 KB');
        expect(Formatters.formatBytes(1536, decimals: 2), '1.50 KB');
        expect(Formatters.formatBytes(1536, decimals: 3), '1.500 KB');
      });
    });

    group('formatKilobytes', () {
      test('formats null as 0 KB', () {
        expect(Formatters.formatKilobytes(null), '0 KB');
      });

      test('converts kilobytes to bytes and formats', () {
        expect(Formatters.formatKilobytes(1), '1.0 KB');
        expect(Formatters.formatKilobytes(1024), '1.0 MB');
        expect(Formatters.formatKilobytes(1048576), '1.0 GB');
      });

      test('respects decimal parameter', () {
        expect(Formatters.formatKilobytes(1.5, decimals: 0), '2 KB');
        expect(Formatters.formatKilobytes(1.5, decimals: 2), '1.50 KB');
      });
    });

    group('formatUptime', () {
      test('returns Unknown for null or empty string', () {
        expect(Formatters.formatUptime(null), 'Unknown');
        expect(Formatters.formatUptime(''), 'Unknown');
      });

      test('returns Unknown for invalid date string', () {
        expect(Formatters.formatUptime('invalid-date'), 'Unknown');
      });

      test('formats uptime with days, hours, and minutes', () {
        final bootTime = DateTime.now().subtract(const Duration(
          days: 5,
          hours: 3,
          minutes: 12,
        )).toIso8601String();
        
        final result = Formatters.formatUptime(bootTime);
        expect(result, contains('5d'));
        expect(result, contains('3h'));
        expect(result, contains('12m'));
      });

      test('formats uptime with only hours and minutes', () {
        final bootTime = DateTime.now().subtract(const Duration(
          hours: 3,
          minutes: 12,
        )).toIso8601String();
        
        final result = Formatters.formatUptime(bootTime);
        expect(result, '3h 12m');
      });

      test('formats uptime with only minutes', () {
        final bootTime = DateTime.now().subtract(const Duration(
          minutes: 45,
        )).toIso8601String();
        
        final result = Formatters.formatUptime(bootTime);
        expect(result, '45m');
      });
    });

    group('formatTemperature', () {
      test('returns -- for null', () {
        expect(Formatters.formatTemperature(null), '--');
      });

      test('formats temperature with °C suffix', () {
        expect(Formatters.formatTemperature(25), '25°C');
        expect(Formatters.formatTemperature(0), '0°C');
        expect(Formatters.formatTemperature(-10), '-10°C');
        expect(Formatters.formatTemperature(100), '100°C');
      });
    });

    group('usagePercent', () {
      test('returns 0 when used is null', () {
        expect(Formatters.usagePercent(null, 100), 0);
      });

      test('returns 0 when total is null', () {
        expect(Formatters.usagePercent(50, null), 0);
      });

      test('returns 0 when total is 0', () {
        expect(Formatters.usagePercent(50, 0), 0);
      });

      test('calculates correct percentage', () {
        expect(Formatters.usagePercent(25, 100), 0.25);
        expect(Formatters.usagePercent(50, 100), 0.5);
        expect(Formatters.usagePercent(75, 100), 0.75);
        expect(Formatters.usagePercent(100, 100), 1.0);
      });

      test('clamps to 0.0 minimum', () {
        expect(Formatters.usagePercent(-50, 100), 0.0);
      });

      test('clamps to 1.0 maximum', () {
        expect(Formatters.usagePercent(150, 100), 1.0);
      });
    });

    group('formatState', () {
      test('capitalizes first letter and lowercases rest', () {
        expect(Formatters.formatState('running'), 'Running');
        expect(Formatters.formatState('STOPPED'), 'Stopped');
        expect(Formatters.formatState('PaUsEd'), 'Paused');
      });

      test('replaces underscores with spaces', () {
        expect(Formatters.formatState('NOT_RUNNING'), 'Not Running');
        expect(Formatters.formatState('LONG_STATE_NAME'), 'Long State Name');
      });

      test('handles multiple underscores', () {
        expect(Formatters.formatState('VERY_LONG_STATE_NAME'), 'Very Long State Name');
      });

      test('handles single character states', () {
        expect(Formatters.formatState('a'), 'A');
      });

      test('handles empty string', () {
        expect(Formatters.formatState(''), '');
      });
    });
  });
}
