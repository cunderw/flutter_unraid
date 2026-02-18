import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/data/models/share.dart';

void main() {
  group('Share', () {
    test('creates from json with all fields', () {
      final json = {
        'id': 'share-123',
        'name': 'appdata',
        'free': 500000000000,
        'used': 100000000000,
        'size': 600000000000,
        'comment': 'Application data',
        'cache': true,
        'include': ['disk1', 'disk2'],
        'exclude': ['disk3'],
        'allocator': 'highwater',
        'splitLevel': 'auto',
        'floor': '1GB',
        'cow': 'auto',
        'color': 'blue',
        'luksStatus': 'encrypted',
      };

      final share = Share.fromJson(json);

      expect(share.id, 'share-123');
      expect(share.name, 'appdata');
      expect(share.free, 500000000000);
      expect(share.used, 100000000000);
      expect(share.size, 600000000000);
      expect(share.comment, 'Application data');
      expect(share.cache, true);
      expect(share.include, ['disk1', 'disk2']);
      expect(share.exclude, ['disk3']);
      expect(share.allocator, 'highwater');
      expect(share.splitLevel, 'auto');
      expect(share.floor, '1GB');
      expect(share.cow, 'auto');
      expect(share.color, 'blue');
      expect(share.luksStatus, 'encrypted');
    });

    test('creates from json with minimal fields', () {
      final json = {
        'id': 'share-123',
      };

      final share = Share.fromJson(json);

      expect(share.id, 'share-123');
      expect(share.name, isNull);
      expect(share.free, isNull);
      expect(share.used, isNull);
      expect(share.size, isNull);
      expect(share.comment, isNull);
      expect(share.cache, isNull);
      expect(share.include, isNull);
      expect(share.exclude, isNull);
      expect(share.allocator, isNull);
      expect(share.splitLevel, isNull);
      expect(share.floor, isNull);
      expect(share.cow, isNull);
      expect(share.color, isNull);
      expect(share.luksStatus, isNull);
    });

    test('displayName returns name when present', () {
      const share = Share(id: 'share-123', name: 'appdata');

      expect(share.displayName, 'appdata');
    });

    test('displayName returns id when name is null', () {
      const share = Share(id: 'share-123');

      expect(share.displayName, 'share-123');
    });

    test('usagePercent calculates correctly', () {
      const share = Share(
        id: 'share-123',
        used: 250,
        size: 1000,
      );

      expect(share.usagePercent, 0.25);
    });

    test('usagePercent returns 0 when used is null', () {
      const share = Share(
        id: 'share-123',
        size: 1000,
      );

      expect(share.usagePercent, 0);
    });

    test('usagePercent returns 0 when size is null', () {
      const share = Share(
        id: 'share-123',
        used: 250,
      );

      expect(share.usagePercent, 0);
    });

    test('usagePercent returns 0 when size is 0', () {
      const share = Share(
        id: 'share-123',
        used: 250,
        size: 0,
      );

      expect(share.usagePercent, 0);
    });

    test('usagePercent clamps to 1.0 when used exceeds size', () {
      const share = Share(
        id: 'share-123',
        used: 1500,
        size: 1000,
      );

      expect(share.usagePercent, 1.0);
    });

    test('usagePercent clamps to 0.0 when negative', () {
      const share = Share(
        id: 'share-123',
        used: -100,
        size: 1000,
      );

      expect(share.usagePercent, 0.0);
    });
  });
}
