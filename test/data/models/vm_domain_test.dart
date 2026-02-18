import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/data/models/vm_domain.dart';

import '../../helpers/factories.dart';

void main() {
  group('VmDomain', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'id': 'vm-1',
          'name': 'TestVM',
          'state': 'RUNNING',
          'cpus': 4,
          'memory': 4294967296,
          'autostart': true,
          'template': 'Ubuntu',
          'description': 'Test VM',
        };
        final vm = VmDomain.fromJson(json);
        expect(vm.id, 'vm-1');
        expect(vm.name, 'TestVM');
        expect(vm.state, 'RUNNING');
        expect(vm.cpus, 4);
        expect(vm.memory, 4294967296);
        expect(vm.autostart, true);
        expect(vm.template, 'Ubuntu');
        expect(vm.description, 'Test VM');
      });

      test('handles missing optional fields', () {
        final json = {'id': 'vm-1'};
        final vm = VmDomain.fromJson(json);
        expect(vm.id, 'vm-1');
        expect(vm.name, isNull);
        expect(vm.state, 'NOSTATE');
        expect(vm.cpus, isNull);
        expect(vm.memory, isNull);
        expect(vm.autostart, isNull);
        expect(vm.template, isNull);
        expect(vm.description, isNull);
      });
    });

    group('displayName', () {
      test('returns name when present', () {
        final vm = makeVmDomain(name: 'TestVM');
        expect(vm.displayName, 'TestVM');
      });

      test('returns id when name is null', () {
        final vm = makeVmDomain(id: 'vm-1', name: null);
        expect(vm.displayName, 'vm-1');
      });
    });

    group('state getters', () {
      test('isRunning returns true when state is RUNNING', () {
        final vm = makeRunningVm();
        expect(vm.isRunning, true);
        expect(vm.isPaused, false);
        expect(vm.isStopped, false);
        expect(vm.isCrashed, false);
      });

      test('isPaused returns true when state is PAUSED', () {
        final vm = makePausedVm();
        expect(vm.isRunning, false);
        expect(vm.isPaused, true);
        expect(vm.isStopped, false);
        expect(vm.isCrashed, false);
      });

      test('isStopped returns true when state is SHUTOFF', () {
        final vm = makeStoppedVm();
        expect(vm.isRunning, false);
        expect(vm.isPaused, false);
        expect(vm.isStopped, true);
        expect(vm.isCrashed, false);
      });

      test('isCrashed returns true when state is CRASHED', () {
        final vm = makeVmDomain(state: 'CRASHED');
        expect(vm.isRunning, false);
        expect(vm.isPaused, false);
        expect(vm.isStopped, false);
        expect(vm.isCrashed, true);
      });
    });

    group('memoryDisplay', () {
      test('returns N/A when memory is null', () {
        final vm = makeVmDomain(memory: null);
        expect(vm.memoryDisplay, 'N/A');
      });

      test('returns MB when memory is less than 1GB', () {
        final vm = makeVmDomain(memory: 536870912); // 512 MB
        expect(vm.memoryDisplay, '512 MB');
      });

      test('returns GB when memory is 1GB or more', () {
        final vm = makeVmDomain(memory: 4294967296); // 4 GB
        expect(vm.memoryDisplay, '4.0 GB');
      });
    });
  });
}
