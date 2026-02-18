import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/blocs/shares/shares_state.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/shares_tab.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';

import '../../../../helpers/factories.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_helpers.dart';

void main() {
  late MockSharesCubit mockSharesCubit;

  setUp(() {
    mockSharesCubit = MockSharesCubit();
  });

  group('SharesTab', () {
    testWidgets('displays loading indicator when SharesInitial', (
      tester,
    ) async {
      await tester.pumpAppWithBlocs(
        const SharesTab(),
        sharesCubit: mockSharesCubit,
        sharesState: const SharesInitial(),
      );
      await tester.pump();

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading shares...'), findsOneWidget);
    });

    testWidgets('displays loading indicator when SharesLoading', (
      tester,
    ) async {
      await tester.pumpAppWithBlocs(
        const SharesTab(),
        sharesCubit: mockSharesCubit,
        sharesState: const SharesLoading(),
      );
      await tester.pump();

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('displays error display when SharesError', (tester) async {
      await tester.pumpAppWithBlocs(
        const SharesTab(),
        sharesCubit: mockSharesCubit,
        sharesState: const SharesError('Failed to load shares'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDisplay), findsOneWidget);
      expect(find.text('Failed to load shares'), findsOneWidget);
    });

    testWidgets('displays empty state when no shares', (tester) async {
      await tester.pumpAppWithBlocs(
        const SharesTab(),
        sharesCubit: mockSharesCubit,
        sharesState: const SharesLoaded([]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No shares found.'), findsOneWidget);
      expect(find.byIcon(Icons.folder_shared_outlined), findsOneWidget);
    });

    testWidgets('displays shares when SharesLoaded with data', (tester) async {
      final shares = [
        makeShare(id: 's1', name: 'appdata'),
        makeShare(id: 's2', name: 'media'),
      ];

      await tester.pumpAppWithBlocs(
        const SharesTab(),
        sharesCubit: mockSharesCubit,
        sharesState: SharesLoaded(shares),
      );
      await tester.pumpAndSettle();

      expect(find.text('SHARES'), findsOneWidget);
      expect(find.text('2 total'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('displays share tiles with names', (tester) async {
      final shares = [
        makeShare(id: 's1', name: 'appdata'),
        makeShare(id: 's2', name: 'media'),
      ];

      await tester.pumpAppWithBlocs(
        const SharesTab(),
        sharesCubit: mockSharesCubit,
        sharesState: SharesLoaded(shares),
      );
      await tester.pumpAndSettle();

      expect(find.text('appdata'), findsOneWidget);
      expect(find.text('media'), findsOneWidget);
    });

    testWidgets('displays folder icon for shares', (tester) async {
      final shares = [makeShare()];

      await tester.pumpAppWithBlocs(
        const SharesTab(),
        sharesCubit: mockSharesCubit,
        sharesState: SharesLoaded(shares),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder), findsOneWidget);
    });
  });
}
