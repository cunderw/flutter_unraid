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

    group('Equatable', () {
      test('two ports with same values are equal', () {
        final a = makeContainerPort();
        final b = makeContainerPort();
        expect(a, equals(b));
      });

      test('two ports with different values are not equal', () {
        final a = makeContainerPort(publicPort: 8080);
        final b = makeContainerPort(publicPort: 9090);
        expect(a, isNot(equals(b)));
      });
    });
  });

  group('ContainerMount', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'source': '/mnt/user/appdata/test',
          'destination': '/data',
          'type': 'bind',
          'mode': 'rw',
        };
        final mount = ContainerMount.fromJson(json);
        expect(mount.source, '/mnt/user/appdata/test');
        expect(mount.destination, '/data');
        expect(mount.type, 'bind');
        expect(mount.mode, 'rw');
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};
        final mount = ContainerMount.fromJson(json);
        expect(mount.source, '');
        expect(mount.destination, '');
        expect(mount.type, 'bind');
        expect(mount.mode, 'rw');
      });
    });

    group('isReadOnly', () {
      test('returns true when mode is ro', () {
        final mount = makeContainerMount(mode: 'ro');
        expect(mount.isReadOnly, true);
      });

      test('returns false when mode is rw', () {
        final mount = makeContainerMount(mode: 'rw');
        expect(mount.isReadOnly, false);
      });

      test('handles case-insensitive comparison', () {
        final mount = makeContainerMount(mode: 'RO');
        expect(mount.isReadOnly, true);
      });
    });

    group('Equatable', () {
      test('two mounts with same values are equal', () {
        final a = makeContainerMount();
        final b = makeContainerMount();
        expect(a, equals(b));
      });

      test('two mounts with different values are not equal', () {
        final a = makeContainerMount(source: '/a');
        final b = makeContainerMount(source: '/b');
        expect(a, isNot(equals(b)));
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
          'mounts': [
            {
              'source': '/mnt/user/appdata/nginx',
              'destination': '/data',
              'type': 'bind',
              'mode': 'rw',
            },
          ],
          'iconUrl': 'http://example.com/icon.png',
          'webUiUrl': 'http://localhost:8080',
          'templatePath': '/path/to/template.xml',
          'projectUrl': 'https://github.com/example/project',
          'supportUrl': 'https://forums.example.com',
          'registryUrl': 'https://hub.docker.com/r/example/project',
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
        expect(container.mounts.length, 1);
        expect(container.mounts.first.source, '/mnt/user/appdata/nginx');
        expect(container.iconUrl, 'http://example.com/icon.png');
        expect(container.webUiUrl, 'http://localhost:8080');
        expect(container.templatePath, '/path/to/template.xml');
        expect(container.projectUrl, 'https://github.com/example/project');
        expect(container.supportUrl, 'https://forums.example.com');
        expect(
          container.registryUrl,
          'https://hub.docker.com/r/example/project',
        );
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
        expect(container.mounts, isEmpty);
        expect(container.iconUrl, isNull);
        expect(container.webUiUrl, isNull);
        expect(container.templatePath, isNull);
        expect(container.projectUrl, isNull);
        expect(container.supportUrl, isNull);
        expect(container.registryUrl, isNull);
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

    group('hasMounts', () {
      test('returns true when mounts is not empty', () {
        final container = makeContainerWithMounts();
        expect(container.hasMounts, true);
      });

      test('returns false when mounts is empty', () {
        final container = makeDockerContainer();
        expect(container.hasMounts, false);
      });
    });

    group('hasLinks', () {
      test('returns true when projectUrl is set', () {
        final container = makeDockerContainer(
          projectUrl: 'https://example.com',
        );
        expect(container.hasLinks, true);
      });

      test('returns true when supportUrl is set', () {
        final container = makeDockerContainer(
          supportUrl: 'https://example.com',
        );
        expect(container.hasLinks, true);
      });

      test('returns true when registryUrl is set', () {
        final container = makeDockerContainer(
          registryUrl: 'https://example.com',
        );
        expect(container.hasLinks, true);
      });

      test('returns false when no URLs are set', () {
        final container = makeDockerContainer();
        expect(container.hasLinks, false);
      });
    });

    group('Equatable', () {
      test('two containers with same values are equal', () {
        final a = makeDockerContainer();
        final b = makeDockerContainer();
        expect(a, equals(b));
      });

      test('two containers with different ids are not equal', () {
        final a = makeDockerContainer(id: 'a');
        final b = makeDockerContainer(id: 'b');
        expect(a, isNot(equals(b)));
      });
    });
  });
}
