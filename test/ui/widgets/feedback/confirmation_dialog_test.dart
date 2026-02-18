import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/feedback/confirmation_dialog.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('showConfirmationDialog', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showConfirmationDialog(
              context,
              title: 'Confirm Action',
              message: 'Are you sure?',
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Action'), findsOneWidget);
    });

    testWidgets('displays message', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showConfirmationDialog(
              context,
              title: 'Title',
              message: 'Are you sure you want to proceed?',
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to proceed?'), findsOneWidget);
    });

    testWidgets('displays default confirm and cancel labels', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showConfirmationDialog(
              context,
              title: 'Title',
              message: 'Message',
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays custom confirm and cancel labels', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showConfirmationDialog(
              context,
              title: 'Title',
              message: 'Message',
              confirmLabel: 'Delete',
              cancelLabel: 'Keep',
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Keep'), findsOneWidget);
    });

    testWidgets('returns true when confirm is pressed', (tester) async {
      bool? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showConfirmationDialog(
                context,
                title: 'Title',
                message: 'Message',
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('returns false when cancel is pressed', (tester) async {
      bool? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showConfirmationDialog(
                context,
                title: 'Title',
                message: 'Message',
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('is an AlertDialog', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showConfirmationDialog(
              context,
              title: 'Title',
              message: 'Message',
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
