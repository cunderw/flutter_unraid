import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/data/models/share.dart';

import '../../helpers/factories.dart';

void main() {
  group('Share', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'id': 'share-1',
          'name': 'appdata',
          'free': 500,
          'used': 500,
          'size': 1000,
          'comment': 'Application data',
          'cache': true,
          'include': ['disk1', 'disk2'],
          'exclude': ['disk3'],
          'allocator': 'highwater',
          'splitLevel': '2',
          'floor': '100',
          'cow': 'yes',
          'color': 'green-on',
          'luksStatus': 'unlocked',
        };
        final share = Share.fromJson(json);
        expect(share.id, 'share-1');
        expect(share.name, 'appdata');
        expect(share.free, 500);
        expect(share.used, 500);
        expect(share.size, 1000);
        expect(share.comment, 'Application data');
        expect(share.cache, true);
        expect(share.include, ['disk1', 'disk2']);
        expect(share.exclude, ['disk3']);
        expect(share.allocator, 'highwater');
        expect(share.splitLevel, '2');
        expect(share.floor, '100');
        expect(share.cow, 'yes');
        expect(share.color, 'green-on');
        expect(share.luksStatus, 'unlocked');
      });

      test('handles missing optional fields', () {
        final json = {'id': 'share-1'};
        final share = Share.fromJson(json);
        expect(share.id, 'share-1');
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
    });

    group('displayName', () {
      test('returns name when present', () {
        final share = makeShare(name: 'appdata');
        expect(share.displayName, 'appdata');
      });

      test('returns id when name is null', () {
        final share = makeShare(id: 'share-1', name: null);
        expect(share.displayName, 'share-1');
      });
    });

    group('usagePercent', () {
      test('calculates usage percentage correctly', () {
        final share = makeShare(used: 250, size: 1000);
        expect(share.usagePercent, 0.25);
      });

      test('returns 0 when used is null', () {
        final share = makeShare(used: null, size: 1000);
        expect(share.usagePercent, 0);
      });

      test('returns 0 when size is null', () {
        final share = makeShare(used: 500, size: null);
        expect(share.usagePercent, 0);
      });

      test('returns 0 when size is 0', () {
        final share = makeShare(used: 500, size: 0);
        expect(share.usagePercent, 0);
      });

      test('clamps usage to 1.0 when used > size', () {
        final share = makeShare(used: 1500, size: 1000);
        expect(share.usagePercent, 1.0);
      });

      test('returns full usage when used equals size', () {
        final share = makeShare(used: 1000, size: 1000);
        expect(share.usagePercent, 1.0);
      });
    });
  });
}
