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

      expect(find.text('Configuration'), findsOneWidget);
    });

    testWidgets('displays image information', (tester) async {
      final container = makeRunningContainer(
        image: 'nginx:latest',
        imageId: 'sha256:abc123',
      );
      await tester.pumpApp(ContainerConfigSection(container: container));

      expect(find.text('Image'), findsOneWidget);
      expect(find.text('nginx:latest'), findsOneWidget);
    });

    testWidgets('displays image ID', (tester) async {
      final container = makeRunningContainer(imageId: 'sha256:abc123');
      await tester.pumpApp(ContainerConfigSection(container: container));

      expect(find.text('Image ID'), findsOneWidget);
      expect(find.text('sha256:abc123'), findsOneWidget);
    });

    testWidgets('displays container ID', (tester) async {
      final container = makeRunningContainer(id: 'container-123');
      await tester.pumpApp(ContainerConfigSection(container: container));

      expect(find.text('Container ID'), findsOneWidget);
      expect(find.text('container-123'), findsOneWidget);
    });

    testWidgets('displays auto start as Yes when true', (tester) async {
      final container = makeRunningContainer(autoStart: true);
      await tester.pumpApp(ContainerConfigSection(container: container));

      expect(find.text('Auto Start'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
    });

    testWidgets('displays auto start as No when false', (tester) async {
      final container = makeRunningContainer(autoStart: false);
      await tester.pumpApp(ContainerConfigSection(container: container));

      expect(find.text('Auto Start'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('uses KeyValueRow widgets', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerConfigSection(container: container));

      expect(find.byType(KeyValueRow), findsNWidgets(4));
    });

    testWidgets('displays in a card', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerConfigSection(container: container));

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
