import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/screens/container_detail/container_mounts_section.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  group('ContainerMountsSection', () {
    testWidgets('displays Mounts title', (tester) async {
      final container = makeContainerWithMounts();
      await tester.pumpApp(ContainerMountsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Mounts'), findsOneWidget);
    });

    testWidgets('displays mount source path', (tester) async {
      final container = makeDockerContainer(
        mounts: [makeContainerMount(source: '/mnt/user/appdata/test')],
      );
      await tester.pumpApp(ContainerMountsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('/mnt/user/appdata/test'), findsOneWidget);
    });

    testWidgets('displays mount destination path', (tester) async {
      final container = makeDockerContainer(
        mounts: [makeContainerMount(destination: '/data')],
      );
      await tester.pumpApp(ContainerMountsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('/data'), findsOneWidget);
    });

    testWidgets('displays mount type badge', (tester) async {
      final container = makeDockerContainer(
        mounts: [makeContainerMount(type: 'bind')],
      );
      await tester.pumpApp(ContainerMountsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('bind'), findsOneWidget);
    });

    testWidgets('displays mount mode badge', (tester) async {
      final container = makeDockerContainer(
        mounts: [makeContainerMount(mode: 'rw')],
      );
      await tester.pumpApp(ContainerMountsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('rw'), findsOneWidget);
    });

    testWidgets('displays multiple mounts', (tester) async {
      final container = makeContainerWithMounts();
      await tester.pumpApp(ContainerMountsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_outlined), findsNWidgets(2));
    });

    testWidgets('displays arrow icon between source and destination', (
      tester,
    ) async {
      final container = makeDockerContainer(mounts: [makeContainerMount()]);
      await tester.pumpApp(ContainerMountsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('displays ro badge for read-only mount', (tester) async {
      final container = makeDockerContainer(
        mounts: [makeContainerMount(mode: 'ro')],
      );
      await tester.pumpApp(ContainerMountsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('ro'), findsOneWidget);
    });

    testWidgets('displays in a card', (tester) async {
      final container = makeContainerWithMounts();
      await tester.pumpApp(ContainerMountsSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
