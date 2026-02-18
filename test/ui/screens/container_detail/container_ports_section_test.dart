import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/screens/container_detail/container_ports_section.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  group('ContainerPortsSection', () {
    testWidgets('displays Ports title', (tester) async {
      final container = makeRunningContainer(ports: [makeContainerPort()]);
      await tester.pumpApp(ContainerPortsSection(container: container));

      expect(find.text('Ports'), findsOneWidget);
    });

    testWidgets('displays port information', (tester) async {
      final port = makeContainerPort(
        hostPort: '8080',
        containerPort: '80',
        protocol: 'tcp',
      );
      final container = makeRunningContainer(ports: [port]);
      await tester.pumpApp(ContainerPortsSection(container: container));

      expect(find.text('8080:80/tcp'), findsOneWidget);
    });

    testWidgets('displays port IP when available', (tester) async {
      final port = makeContainerPort(
        hostPort: '8080',
        containerPort: '80',
        ip: '0.0.0.0',
      );
      final container = makeRunningContainer(ports: [port]);
      await tester.pumpApp(ContainerPortsSection(container: container));

      expect(find.text('0.0.0.0'), findsOneWidget);
    });

    testWidgets('displays multiple ports', (tester) async {
      final ports = [
        makeContainerPort(hostPort: '8080', containerPort: '80'),
        makeContainerPort(hostPort: '8443', containerPort: '443'),
      ];
      final container = makeRunningContainer(ports: ports);
      await tester.pumpApp(ContainerPortsSection(container: container));

      expect(find.text('8080:80/tcp'), findsOneWidget);
      expect(find.text('8443:443/tcp'), findsOneWidget);
    });

    testWidgets('displays port icon for each port', (tester) async {
      final ports = [
        makeContainerPort(hostPort: '8080', containerPort: '80'),
        makeContainerPort(hostPort: '8443', containerPort: '443'),
      ];
      final container = makeRunningContainer(ports: ports);
      await tester.pumpApp(ContainerPortsSection(container: container));

      expect(find.byIcon(Icons.lan_outlined), findsNWidgets(2));
    });

    testWidgets('displays in a card', (tester) async {
      final container = makeRunningContainer(ports: [makeContainerPort()]);
      await tester.pumpApp(ContainerPortsSection(container: container));

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
