import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/data/models/system_info.dart';

void main() {
  group('OsInfo', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'platform': 'linux',
          'distro': 'Unraid',
          'release': '6.12.0',
          'uptime': '2025-01-01T00:00:00.000Z',
        };
        final os = OsInfo.fromJson(json);
        expect(os.platform, 'linux');
        expect(os.distro, 'Unraid');
        expect(os.release, '6.12.0');
        expect(os.uptime, '2025-01-01T00:00:00.000Z');
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{};
        final os = OsInfo.fromJson(json);
        expect(os.platform, isNull);
        expect(os.distro, isNull);
        expect(os.release, isNull);
        expect(os.uptime, isNull);
      });
    });
  });

  group('CpuInfo', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'manufacturer': 'Intel',
          'brand': 'Xeon E-2288G',
          'cores': 8,
          'threads': 16,
        };
        final cpu = CpuInfo.fromJson(json);
        expect(cpu.manufacturer, 'Intel');
        expect(cpu.brand, 'Xeon E-2288G');
        expect(cpu.cores, 8);
        expect(cpu.threads, 16);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{};
        final cpu = CpuInfo.fromJson(json);
        expect(cpu.manufacturer, isNull);
        expect(cpu.brand, isNull);
        expect(cpu.cores, isNull);
        expect(cpu.threads, isNull);
      });
    });
  });

  group('MemoryUtilization', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'total': 34359738368,
          'free': 17179869184,
          'used': 17179869184,
          'active': 12884901888,
          'available': 21474836480,
          'percentTotal': 50.0,
        };
        final memory = MemoryUtilization.fromJson(json);
        expect(memory.total, 34359738368);
        expect(memory.free, 17179869184);
        expect(memory.used, 17179869184);
        expect(memory.active, 12884901888);
        expect(memory.available, 21474836480);
        expect(memory.percentTotal, 50.0);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{};
        final memory = MemoryUtilization.fromJson(json);
        expect(memory.total, isNull);
        expect(memory.free, isNull);
        expect(memory.used, isNull);
        expect(memory.active, isNull);
        expect(memory.available, isNull);
        expect(memory.percentTotal, isNull);
      });

      test('converts num to double for percentTotal', () {
        final json = {'percentTotal': 50};
        final memory = MemoryUtilization.fromJson(json);
        expect(memory.percentTotal, isA<double>());
        expect(memory.percentTotal, 50.0);
      });
    });
  });

  group('SystemInfo', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'os': {
            'platform': 'linux',
            'distro': 'Unraid',
            'release': '6.12.0',
            'uptime': '2025-01-01T00:00:00.000Z',
          },
          'cpu': {
            'manufacturer': 'Intel',
            'brand': 'Xeon E-2288G',
            'cores': 8,
            'threads': 16,
          },
        };
        final info = SystemInfo.fromJson(json);
        expect(info.os, isNotNull);
        expect(info.os!.platform, 'linux');
        expect(info.cpu, isNotNull);
        expect(info.cpu!.manufacturer, 'Intel');
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{};
        final info = SystemInfo.fromJson(json);
        expect(info.os, isNull);
        expect(info.cpu, isNull);
      });
    });
  });
}
