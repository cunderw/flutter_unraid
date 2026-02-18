import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/screens/container_detail/container_actions_section.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  late MockDockerCubit mockDockerCubit;

  setUp(() {
    mockDockerCubit = MockDockerCubit();
  });

  group('ContainerActionsSection', () {
    testWidgets('displays Actions title', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpAppWithBlocs(
        ContainerActionsSection(container: container),
        dockerCubit: mockDockerCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('displays Start action for stopped container', (tester) async {
      final container = makeStoppedContainer();
      await tester.pumpAppWithBlocs(
        ContainerActionsSection(container: container),
        dockerCubit: mockDockerCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Start'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('displays Stop and Restart actions for running container', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpAppWithBlocs(
        ContainerActionsSection(container: container),
        dockerCubit: mockDockerCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt), findsOneWidget);
    });

    testWidgets('does not display Start action for running container', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpAppWithBlocs(
        ContainerActionsSection(container: container),
        dockerCubit: mockDockerCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Start'), findsNothing);
    });

    testWidgets('does not display Stop/Restart actions for stopped container', (tester) async {
      final container = makeStoppedContainer();
      await tester.pumpAppWithBlocs(
        ContainerActionsSection(container: container),
        dockerCubit: mockDockerCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Stop'), findsNothing);
      expect(find.text('Restart'), findsNothing);
    });

    testWidgets('displays in a card', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpAppWithBlocs(
        ContainerActionsSection(container: container),
        dockerCubit: mockDockerCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('action chips are wrapped', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpAppWithBlocs(
        ContainerActionsSection(container: container),
        dockerCubit: mockDockerCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(ActionChip), findsNWidgets(2));
    });
  });
}
