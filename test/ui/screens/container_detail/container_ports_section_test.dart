import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/screens/container_detail/container_ports_section.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  group('ContainerPortsSection', () {
    testWidgets('displays Ports title', (tester) async {
      final container = makeDockerContainer(
        state: "RUNNING",
        ports: [makeContainerPort()],
      );
      await tester.pumpApp(ContainerPortsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Ports'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays port information', (tester) async {
      final port = makeContainerPort(
        publicPort: 8080,
        privatePort: 80,
        type: 'tcp',
      );
      final container = makeDockerContainer(state: "RUNNING", ports: [port]);
      await tester.pumpApp(ContainerPortsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('8080:80/tcp'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays port IP when available', (tester) async {
      final port = makeContainerPort(
        publicPort: 8080,
        privatePort: 80,
        ip: '0.0.0.0',
      );
      final container = makeDockerContainer(state: "RUNNING", ports: [port]);
      await tester.pumpApp(ContainerPortsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('0.0.0.0'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays multiple ports', (tester) async {
      final ports = [
        makeContainerPort(publicPort: 8080, privatePort: 80),
        makeContainerPort(publicPort: 8443, privatePort: 443),
      ];
      final container = makeDockerContainer(state: "RUNNING", ports: ports);
      await tester.pumpApp(ContainerPortsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('8080:80/tcp'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('8443:443/tcp'), findsOneWidget);
    });

    testWidgets('displays port icon for each port', (tester) async {
      final ports = [
        makeContainerPort(publicPort: 8080, privatePort: 80),
        makeContainerPort(publicPort: 8443, privatePort: 443),
      ];
      final container = makeDockerContainer(state: "RUNNING", ports: ports);
      await tester.pumpApp(ContainerPortsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lan_outlined), findsNWidgets(2));
      await tester.pumpAndSettle();
    });

    testWidgets('displays in a card', (tester) async {
      final container = makeDockerContainer(
        state: "RUNNING",
        ports: [makeContainerPort()],
      );
      await tester.pumpApp(ContainerPortsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
