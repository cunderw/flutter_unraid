import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/data/models/docker_container.dart';

import '../../helpers/factories.dart';

void main() {
  group('ContainerPort', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'ip': '0.0.0.0',
          'privatePort': 80,
          'publicPort': 8080,
          'type': 'TCP',
        };
        final port = ContainerPort.fromJson(json);
        expect(port.ip, '0.0.0.0');
        expect(port.privatePort, 80);
        expect(port.publicPort, 8080);
        expect(port.type, 'TCP');
      });

      test('handles missing optional fields', () {
        final json = {'type': 'UDP'};
        final port = ContainerPort.fromJson(json);
        expect(port.ip, isNull);
        expect(port.privatePort, isNull);
        expect(port.publicPort, isNull);
        expect(port.type, 'UDP');
      });

      test('defaults type to TCP when missing', () {
        final json = <String, dynamic>{};
        final port = ContainerPort.fromJson(json);
        expect(port.type, 'TCP');
      });
    });

    group('displayString', () {
      test('includes public and private ports when both present', () {
        final port = makeContainerPort(publicPort: 8080, privatePort: 80);
        expect(port.displayString, '8080:80/tcp');
      });

      test('shows only private port when public port is null', () {
        final port = makeContainerPort(publicPort: null, privatePort: 80);
        expect(port.displayString, '80/tcp');
      });

      test('shows type in lowercase', () {
        final port = makeContainerPort(type: 'UDP');
        expect(port.displayString, '8080:80/udp');
      });
    });
  });

  group('DockerContainer', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'id': 'container-1',
          'names': ['/nginx'],
          'image': 'nginx:latest',
          'imageId': 'sha256:abc123',
          'state': 'RUNNING',
          'status': 'Up 2 hours',
          'autoStart': true,
          'ports': [
            {
              'ip': '0.0.0.0',
              'privatePort': 80,
              'publicPort': 8080,
              'type': 'TCP',
            },
          ],
          'iconUrl': 'http://example.com/icon.png',
          'webUiUrl': 'http://localhost:8080',
          'templatePath': '/path/to/template.xml',
        };
        final container = DockerContainer.fromJson(json);
        expect(container.id, 'container-1');
        expect(container.names, ['/nginx']);
        expect(container.image, 'nginx:latest');
        expect(container.imageId, 'sha256:abc123');
        expect(container.state, 'RUNNING');
        expect(container.status, 'Up 2 hours');
        expect(container.autoStart, true);
        expect(container.ports.length, 1);
        expect(container.iconUrl, 'http://example.com/icon.png');
        expect(container.webUiUrl, 'http://localhost:8080');
        expect(container.templatePath, '/path/to/template.xml');
      });

      test('handles missing optional fields with defaults', () {
        final json = {
          'id': 'container-1',
        };
        final container = DockerContainer.fromJson(json);
        expect(container.id, 'container-1');
        expect(container.names, isEmpty);
        expect(container.image, '');
        expect(container.imageId, '');
        expect(container.state, 'UNKNOWN');
        expect(container.status, '');
        expect(container.autoStart, false);
        expect(container.ports, isEmpty);
        expect(container.iconUrl, isNull);
        expect(container.webUiUrl, isNull);
        expect(container.templatePath, isNull);
      });
    });

    group('displayName', () {
      test('returns name without leading slash', () {
        final container = makeDockerContainer(names: ['/nginx']);
        expect(container.displayName, 'nginx');
      });

      test('returns Unknown when names is empty', () {
        final container = makeDockerContainer(names: []);
        expect(container.displayName, 'Unknown');
      });

      test('returns first name when multiple names present', () {
        final container = makeDockerContainer(names: ['/nginx', '/webserver']);
        expect(container.displayName, 'nginx');
      });
    });

    group('state getters', () {
      test('isRunning returns true when state is RUNNING', () {
        final container = makeRunningContainer();
        expect(container.isRunning, true);
        expect(container.isPaused, false);
        expect(container.isStopped, false);
      });

      test('isPaused returns true when state is PAUSED', () {
        final container = makePausedContainer();
        expect(container.isRunning, false);
        expect(container.isPaused, true);
        expect(container.isStopped, false);
      });

      test('isStopped returns true when state is EXITED', () {
        final container = makeStoppedContainer();
        expect(container.isRunning, false);
        expect(container.isPaused, false);
        expect(container.isStopped, true);
      });
    });
  });
}
