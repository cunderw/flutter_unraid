import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/data/models/array_data.dart';

import '../../helpers/factories.dart';

void main() {
  group('Capacity', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'free': '1000000',
          'used': '500000',
          'total': '1500000',
        };
        final capacity = Capacity.fromJson(json);
        expect(capacity.free, '1000000');
        expect(capacity.used, '500000');
        expect(capacity.total, '1500000');
      });

      test('converts numbers to strings', () {
        final json = {
          'free': 1000000,
          'used': 500000,
          'total': 1500000,
        };
        final capacity = Capacity.fromJson(json);
        expect(capacity.free, '1000000');
        expect(capacity.used, '500000');
        expect(capacity.total, '1500000');
      });

      test('defaults missing fields to 0', () {
        final json = <String, dynamic>{};
        final capacity = Capacity.fromJson(json);
        expect(capacity.free, '0');
        expect(capacity.used, '0');
        expect(capacity.total, '0');
      });
    });
  });

  group('ArrayCapacity', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'kilobytes': {'free': '1000000', 'used': '500000', 'total': '1500000'},
          'disks': {'free': '2', 'used': '3', 'total': '5'},
        };
        final capacity = ArrayCapacity.fromJson(json);
        expect(capacity.kilobytes, isNotNull);
        expect(capacity.kilobytes!.free, '1000000');
        expect(capacity.disks, isNotNull);
        expect(capacity.disks!.total, '5');
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{};
        final capacity = ArrayCapacity.fromJson(json);
        expect(capacity.kilobytes, isNull);
        expect(capacity.disks, isNull);
      });
    });
  });

  group('ArrayDisk', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'id': 'disk1',
          'name': 'Disk 1',
          'device': 'sda',
          'size': 4000000000000,
          'status': 'DISK_OK',
          'temp': 35,
          'fsFree': 500,
          'fsUsed': 500,
          'fsSize': 1000,
          'type': 'Data',
          'color': 'green-on',
          'comment': 'Main storage',
          'fsType': 'xfs',
          'numReads': 1000,
          'numWrites': 500,
          'numErrors': 0,
        };
        final disk = ArrayDisk.fromJson(json);
        expect(disk.id, 'disk1');
        expect(disk.name, 'Disk 1');
        expect(disk.device, 'sda');
        expect(disk.size, 4000000000000);
        expect(disk.status, 'DISK_OK');
        expect(disk.temp, 35);
        expect(disk.fsFree, 500);
        expect(disk.fsUsed, 500);
        expect(disk.fsSize, 1000);
        expect(disk.type, 'Data');
        expect(disk.color, 'green-on');
        expect(disk.comment, 'Main storage');
        expect(disk.fsType, 'xfs');
        expect(disk.numReads, 1000);
        expect(disk.numWrites, 500);
        expect(disk.numErrors, 0);
      });

      test('handles missing optional fields', () {
        final json = {'id': 'disk1'};
        final disk = ArrayDisk.fromJson(json);
        expect(disk.id, 'disk1');
        expect(disk.name, isNull);
        expect(disk.device, isNull);
        expect(disk.size, isNull);
        expect(disk.status, isNull);
        expect(disk.temp, isNull);
      });
    });

    group('displayName', () {
      test('returns name when present', () {
        final disk = makeArrayDisk(name: 'Disk 1');
        expect(disk.displayName, 'Disk 1');
      });

      test('returns device when name is null', () {
        final disk = makeArrayDisk(name: null, device: 'sda');
        expect(disk.displayName, 'sda');
      });

      test('returns id when name and device are null', () {
        final disk = makeArrayDisk(id: 'disk1', name: null, device: null);
        expect(disk.displayName, 'disk1');
      });
    });

    group('isHealthy', () {
      test('returns true when status is DISK_OK', () {
        final disk = makeHealthyDisk();
        expect(disk.isHealthy, true);
      });

      test('returns false when status is not DISK_OK', () {
        final disk = makeUnhealthyDisk();
        expect(disk.isHealthy, false);
      });
    });

    group('usagePercent', () {
      test('calculates usage percentage correctly', () {
        final disk = makeArrayDisk(fsUsed: 250, fsSize: 1000);
        expect(disk.usagePercent, 0.25);
      });

      test('returns 0 when fsUsed is null', () {
        final disk = makeArrayDisk(fsUsed: null, fsSize: 1000);
        expect(disk.usagePercent, 0);
      });

      test('returns 0 when fsSize is null', () {
        final disk = makeArrayDisk(fsUsed: 500, fsSize: null);
        expect(disk.usagePercent, 0);
      });

      test('returns 0 when fsSize is 0', () {
        final disk = makeArrayDisk(fsUsed: 500, fsSize: 0);
        expect(disk.usagePercent, 0);
      });

      test('clamps usage to 1.0 when fsUsed > fsSize', () {
        final disk = makeArrayDisk(fsUsed: 1500, fsSize: 1000);
        expect(disk.usagePercent, 1.0);
      });
    });
  });

  group('ArrayData', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'state': 'STARTED',
          'capacity': {
            'kilobytes': {
              'free': '1000000',
              'used': '500000',
              'total': '1500000'
            },
            'disks': {'free': '2', 'used': '3', 'total': '5'},
          },
          'disks': [
            {
              'id': 'disk1',
              'name': 'Disk 1',
              'status': 'DISK_OK',
            },
          ],
          'parities': [
            {
              'id': 'parity1',
              'name': 'Parity',
              'status': 'DISK_OK',
            },
          ],
          'caches': [],
        };
        final array = ArrayData.fromJson(json);
        expect(array.state, 'STARTED');
        expect(array.capacity, isNotNull);
        expect(array.disks.length, 1);
        expect(array.parities.length, 1);
        expect(array.caches, isEmpty);
      });

      test('handles missing optional fields with defaults', () {
        final json = <String, dynamic>{};
        final array = ArrayData.fromJson(json);
        expect(array.state, 'UNKNOWN');
        expect(array.capacity, isNull);
        expect(array.disks, isEmpty);
        expect(array.parities, isEmpty);
        expect(array.caches, isEmpty);
      });
    });

    group('isStarted', () {
      test('returns true when state is STARTED', () {
        final array = makeStartedArray();
        expect(array.isStarted, true);
      });

      test('returns false when state is not STARTED', () {
        final array = makeStoppedArray();
        expect(array.isStarted, false);
      });
    });

    group('totalDisks', () {
      test('counts all disk types', () {
        final array = makeArrayData(
          disks: [makeArrayDisk(id: 'd1'), makeArrayDisk(id: 'd2')],
          parities: [makeArrayDisk(id: 'p1')],
          caches: [makeArrayDisk(id: 'c1')],
        );
        expect(array.totalDisks, 4);
      });

      test('returns 0 when no disks', () {
        final array = makeArrayData(disks: [], parities: [], caches: []);
        expect(array.totalDisks, 0);
      });
    });
  });
}
