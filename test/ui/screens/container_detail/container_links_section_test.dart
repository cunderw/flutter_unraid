import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/screens/container_detail/container_links_section.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  group('ContainerLinksSection', () {
    testWidgets('displays Links title', (tester) async {
      final container = makeContainerWithLinks();
      await tester.pumpApp(ContainerLinksSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Links'), findsOneWidget);
    });

    testWidgets('displays project link when projectUrl is set', (tester) async {
      final container = makeDockerContainer(
        projectUrl: 'https://github.com/example/project',
      );
      await tester.pumpApp(ContainerLinksSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Project'), findsOneWidget);
      expect(find.text('https://github.com/example/project'), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
    });

    testWidgets('displays support link when supportUrl is set', (tester) async {
      final container = makeDockerContainer(
        supportUrl: 'https://forums.example.com',
      );
      await tester.pumpApp(ContainerLinksSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Support'), findsOneWidget);
      expect(find.text('https://forums.example.com'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets('displays registry link when registryUrl is set', (
      tester,
    ) async {
      final container = makeDockerContainer(
        registryUrl: 'https://hub.docker.com/r/example/project',
      );
      await tester.pumpApp(ContainerLinksSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Registry'), findsOneWidget);
      expect(
        find.text('https://hub.docker.com/r/example/project'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
    });

    testWidgets('displays all links when all URLs are set', (tester) async {
      final container = makeContainerWithLinks();
      await tester.pumpApp(ContainerLinksSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Registry'), findsOneWidget);
    });

    testWidgets('shows open_in_new icon for each link', (tester) async {
      final container = makeContainerWithLinks();
      await tester.pumpApp(ContainerLinksSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.open_in_new), findsNWidgets(3));
    });

    testWidgets('displays in a card', (tester) async {
      final container = makeContainerWithLinks();
      await tester.pumpApp(ContainerLinksSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('shows only set links', (tester) async {
      final container = makeDockerContainer(
        projectUrl: 'https://github.com/example',
      );
      await tester.pumpApp(ContainerLinksSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Support'), findsNothing);
      expect(find.text('Registry'), findsNothing);
    });
  });
}
