import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/screens/container_detail/container_config_section.dart';
import 'package:flutter_unraid/ui/widgets/data_display/key_value_row.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  group('ContainerConfigSection', () {
    testWidgets('displays Configuration title', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerConfigSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Configuration'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays image information', (tester) async {
      final container = makeDockerContainer(
        image: 'nginx:latest',
        imageId: 'sha256:abc123',
      );
      await tester.pumpApp(ContainerConfigSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Image'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('nginx:latest'), findsOneWidget);
    });

    testWidgets('displays image ID', (tester) async {
      final container = makeDockerContainer(imageId: 'sha256:abc123');
      await tester.pumpApp(ContainerConfigSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Image ID'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('sha256:abc123'), findsOneWidget);
    });

    testWidgets('displays container ID', (tester) async {
      final container = makeDockerContainer(id: 'container-123');
      await tester.pumpApp(ContainerConfigSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Container ID'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('container-123'), findsOneWidget);
    });

    testWidgets('displays auto start as Yes when true', (tester) async {
      final container = makeDockerContainer(autoStart: true);
      await tester.pumpApp(ContainerConfigSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Auto Start'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Yes'), findsOneWidget);
    });

    testWidgets('displays auto start as No when false', (tester) async {
      final container = makeDockerContainer(autoStart: false);
      await tester.pumpApp(ContainerConfigSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Auto Start'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('uses KeyValueRow widgets', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerConfigSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byType(KeyValueRow), findsNWidgets(4));
      await tester.pumpAndSettle();
    });

    testWidgets('displays Web UI row when webUiUrl is set', (tester) async {
      final container = makeDockerContainer(webUiUrl: 'http://localhost:8080');
      await tester.pumpApp(ContainerConfigSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Web UI'), findsOneWidget);
      expect(find.text('http://localhost:8080'), findsOneWidget);
      // 4 standard KeyValueRows + 1 Web UI row
      expect(find.byType(KeyValueRow), findsNWidgets(5));
    });

    testWidgets('does not display Web UI row when webUiUrl is null', (
      tester,
    ) async {
      final container = makeDockerContainer();
      await tester.pumpApp(ContainerConfigSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Web UI'), findsNothing);
      expect(find.byType(KeyValueRow), findsNWidgets(4));
    });

    testWidgets('displays in a card', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerConfigSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
