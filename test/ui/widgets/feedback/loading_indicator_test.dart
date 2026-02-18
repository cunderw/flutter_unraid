import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('displays circular progress indicator', (tester) async {
      await tester.pumpApp(const LoadingIndicator());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays message when provided', (tester) async {
      await tester.pumpApp(const LoadingIndicator(message: 'Loading data...'));

      expect(find.text('Loading data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not display message when not provided', (tester) async {
      await tester.pumpApp(const LoadingIndicator());

      expect(find.byType(Text), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is centered', (tester) async {
      await tester.pumpApp(const LoadingIndicator());

      expect(find.byType(Center), findsOneWidget);
    });
  });
}
