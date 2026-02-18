import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/inputs/app_text_field.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('AppTextField', () {
    testWidgets('displays label when provided', (tester) async {
      await tester.pumpApp(
        const AppTextField(labelText: 'Username'),
      );

      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('displays hint when provided', (tester) async {
      await tester.pumpApp(
        const AppTextField(hintText: 'Enter your name'),
      );

      // Hint text is in the decoration, find it via TextFormField
      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textField.decoration?.hintText, 'Enter your name');
    });

    testWidgets('displays prefix icon when provided', (tester) async {
      await tester.pumpApp(
        const AppTextField(
          prefixIcon: Icon(Icons.person),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('displays suffix icon when provided', (tester) async {
      await tester.pumpApp(
        const AppTextField(
          suffixIcon: Icon(Icons.visibility),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpApp(
        const AppTextField(obscureText: true),
      );

      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textField.obscureText, isTrue);
    });

    testWidgets('does not obscure text by default', (tester) async {
      await tester.pumpApp(
        const AppTextField(),
      );

      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textField.obscureText, isFalse);
    });

    testWidgets('is read-only when readOnly is true', (tester) async {
      await tester.pumpApp(
        const AppTextField(readOnly: true),
      );

      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textField.readOnly, isTrue);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpApp(
        AppTextField(controller: controller),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello');
      expect(controller.text, 'Hello');
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;
      await tester.pumpApp(
        AppTextField(
          onChanged: (value) => changedValue = value,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test');
      expect(changedValue, 'Test');
    });

    testWidgets('calls onSubmitted when submitted', (tester) async {
      String? submittedValue;
      await tester.pumpApp(
        AppTextField(
          onSubmitted: (value) => submittedValue = value,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Submitted');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submittedValue, 'Submitted');
    });

    testWidgets('validates with validator function', (tester) async {
      await tester.pumpApp(
        Form(
          child: AppTextField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
        ),
      );

      // Trigger validation
      final formState = tester.state<FormState>(find.byType(Form));
      formState.validate();
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('uses TextFormField', (tester) async {
      await tester.pumpApp(
        const AppTextField(),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
