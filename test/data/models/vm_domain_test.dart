import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/data/models/vm_domain.dart';

void main() {
  group('VmDomain', () {
    test('creates from json with all fields', () {
      final json = {
        'id': 'vm-123',
        'name': 'Test VM',
        'state': 'RUNNING',
      };

      final vm = VmDomain.fromJson(json);

      expect(vm.id, 'vm-123');
      expect(vm.name, 'Test VM');
      expect(vm.state, 'RUNNING');
    });

    test('creates from json with minimal fields', () {
      final json = {
        'id': 'vm-123',
      };

      final vm = VmDomain.fromJson(json);

      expect(vm.id, 'vm-123');
      expect(vm.name, isNull);
      expect(vm.state, 'NOSTATE');
    });

    test('displayName returns name when present', () {
      const vm = VmDomain(id: 'vm-123', name: 'Test VM', state: 'RUNNING');

      expect(vm.displayName, 'Test VM');
    });

    test('displayName returns id when name is null', () {
      const vm = VmDomain(id: 'vm-123', state: 'RUNNING');

      expect(vm.displayName, 'vm-123');
    });

    test('isRunning returns true when state is RUNNING', () {
      const vm = VmDomain(id: 'vm-123', name: 'Test', state: 'RUNNING');

      expect(vm.isRunning, true);
      expect(vm.isPaused, false);
      expect(vm.isStopped, false);
      expect(vm.isCrashed, false);
    });

    test('isPaused returns true when state is PAUSED', () {
      const vm = VmDomain(id: 'vm-123', name: 'Test', state: 'PAUSED');

      expect(vm.isRunning, false);
      expect(vm.isPaused, true);
      expect(vm.isStopped, false);
      expect(vm.isCrashed, false);
    });

    test('isStopped returns true when state is SHUTOFF', () {
      const vm = VmDomain(id: 'vm-123', name: 'Test', state: 'SHUTOFF');

      expect(vm.isRunning, false);
      expect(vm.isPaused, false);
      expect(vm.isStopped, true);
      expect(vm.isCrashed, false);
    });

    test('isCrashed returns true when state is CRASHED', () {
      const vm = VmDomain(id: 'vm-123', name: 'Test', state: 'CRASHED');

      expect(vm.isRunning, false);
      expect(vm.isPaused, false);
      expect(vm.isStopped, false);
      expect(vm.isCrashed, true);
    });
  });
}
