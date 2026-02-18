import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';

void main() {
  group('ContainerPort', () {
    test('creates from json with all fields', () {
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

    test('creates from json with missing optional fields', () {
      final json = {
        'type': 'UDP',
      };

      final port = ContainerPort.fromJson(json);

      expect(port.ip, isNull);
      expect(port.privatePort, isNull);
      expect(port.publicPort, isNull);
      expect(port.type, 'UDP');
    });

    test('defaults to TCP when type is missing', () {
      final json = <String, dynamic>{};

      final port = ContainerPort.fromJson(json);

      expect(port.type, 'TCP');
    });

    test('displayString formats port correctly with public and private', () {
      const port = ContainerPort(
        ip: '0.0.0.0',
        privatePort: 80,
        publicPort: 8080,
        type: 'TCP',
      );

      expect(port.displayString, '8080:80/tcp');
    });

    test('displayString formats port correctly without public port', () {
      const port = ContainerPort(
        privatePort: 80,
        type: 'TCP',
      );

      expect(port.displayString, '80/tcp');
    });

    test('displayString formats port correctly without private port', () {
      const port = ContainerPort(
        publicPort: 8080,
        type: 'UDP',
      );

      expect(port.displayString, '8080:/udp');
    });
  });

  group('DockerContainer', () {
    test('creates from json with all fields', () {
      final json = {
        'id': 'abc123',
        'names': ['/container1', '/alias1'],
        'image': 'nginx:latest',
        'imageId': 'sha256:xyz',
        'state': 'RUNNING',
        'status': 'Up 2 hours',
        'autoStart': true,
        'ports': [
          {
            'privatePort': 80,
            'publicPort': 8080,
            'type': 'TCP',
          }
        ],
        'iconUrl': 'http://example.com/icon.png',
        'webUiUrl': 'http://example.com:8080',
        'templatePath': '/templates/nginx.xml',
      };

      final container = DockerContainer.fromJson(json);

      expect(container.id, 'abc123');
      expect(container.names, ['/container1', '/alias1']);
      expect(container.image, 'nginx:latest');
      expect(container.imageId, 'sha256:xyz');
      expect(container.state, 'RUNNING');
      expect(container.status, 'Up 2 hours');
      expect(container.autoStart, true);
      expect(container.ports.length, 1);
      expect(container.iconUrl, 'http://example.com/icon.png');
      expect(container.webUiUrl, 'http://example.com:8080');
      expect(container.templatePath, '/templates/nginx.xml');
    });

    test('creates from json with minimal fields', () {
      final json = {
        'id': 'abc123',
      };

      final container = DockerContainer.fromJson(json);

      expect(container.id, 'abc123');
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

    test('displayName returns first name without leading slash', () {
      const container = DockerContainer(
        id: '123',
        names: ['/container1', '/alias1'],
        image: 'nginx',
        state: 'RUNNING',
        status: 'Up',
        autoStart: true,
      );

      expect(container.displayName, 'container1');
    });

    test('displayName returns Unknown when names is empty', () {
      const container = DockerContainer(
        id: '123',
        names: [],
        image: 'nginx',
        state: 'RUNNING',
        status: 'Up',
        autoStart: true,
      );

      expect(container.displayName, 'Unknown');
    });

    test('isRunning returns true when state is RUNNING', () {
      const container = DockerContainer(
        id: '123',
        names: ['/test'],
        image: 'nginx',
        state: 'RUNNING',
        status: 'Up',
        autoStart: true,
      );

      expect(container.isRunning, true);
      expect(container.isPaused, false);
      expect(container.isStopped, false);
    });

    test('isPaused returns true when state is PAUSED', () {
      const container = DockerContainer(
        id: '123',
        names: ['/test'],
        image: 'nginx',
        state: 'PAUSED',
        status: 'Paused',
        autoStart: true,
      );

      expect(container.isRunning, false);
      expect(container.isPaused, true);
      expect(container.isStopped, false);
    });

    test('isStopped returns true when state is EXITED', () {
      const container = DockerContainer(
        id: '123',
        names: ['/test'],
        image: 'nginx',
        state: 'EXITED',
        status: 'Exited (0)',
        autoStart: true,
      );

      expect(container.isRunning, false);
      expect(container.isPaused, false);
      expect(container.isStopped, true);
    });
  });
}
