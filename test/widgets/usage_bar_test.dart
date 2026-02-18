import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/ui/widgets/data_display/usage_bar.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('UsageBar', () {
    testWidgets('displays progress bar with correct percentage', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(percentage: 0.5),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, 0.5);
    });

    testWidgets('clamps percentage to 0.0 - 1.0 range', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(percentage: 1.5),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, 1.0);
    });

    testWidgets('displays label when provided', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(
            percentage: 0.5,
            label: 'Memory Usage',
          ),
        ),
      );

      expect(find.text('Memory Usage'), findsOneWidget);
    });

    testWidgets('displays detail when provided', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(
            percentage: 0.5,
            detail: '50% used',
          ),
        ),
      );

      expect(find.text('50% used'), findsOneWidget);
    });

    testWidgets('displays both label and detail when provided', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(
            percentage: 0.5,
            label: 'Memory',
            detail: '8GB / 16GB',
          ),
        ),
      );

      expect(find.text('Memory'), findsOneWidget);
      expect(find.text('8GB / 16GB'), findsOneWidget);
    });

    testWidgets('does not display label/detail row when both are null',
        (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(percentage: 0.5),
        ),
      );

      // Only LinearProgressIndicator should be present, no Row for labels
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(Padding), findsNothing);
    });

    testWidgets('uses custom bar color when provided', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(
            percentage: 0.5,
            barColor: Colors.purple,
          ),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, Colors.purple);
    });

    testWidgets('uses green color for low usage (< 75%)', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(percentage: 0.5),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, AppColors.running);
    });

    testWidgets('uses warning color for medium usage (75% - 90%)',
        (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(percentage: 0.8),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, AppColors.warning);
    });

    testWidgets('uses red color for high usage (> 90%)', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(percentage: 0.95),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, AppColors.stopped);
    });

    testWidgets('uses custom height when provided', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(
            percentage: 0.5,
            height: 12,
          ),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.minHeight, 12);
    });

    testWidgets('uses default height of 8 when not provided', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const UsageBar(percentage: 0.5),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.minHeight, 8);
    });
  });
}
