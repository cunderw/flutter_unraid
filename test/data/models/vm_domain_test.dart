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
        };
        final vm = VmDomain.fromJson(json);
        expect(vm.id, 'vm-1');
        expect(vm.name, 'TestVM');
        expect(vm.state, 'RUNNING');
      });

      test('handles missing optional fields', () {
        final json = {'id': 'vm-1'};
        final vm = VmDomain.fromJson(json);
        expect(vm.id, 'vm-1');
        expect(vm.name, isNull);
        expect(vm.state, 'NOSTATE');
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
  });
}
