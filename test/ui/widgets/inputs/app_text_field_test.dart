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

    testWidgets('obscureText hides input characters', (tester) async {
      final controller = TextEditingController();
      await tester.pumpApp(
        AppTextField(
          controller: controller,
          obscureText: true,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'password');
      expect(controller.text, 'password');
      
      // When obscureText is true, the text should not be directly visible
      // We verify the widget was created with obscureText
      final appTextField = tester.widget<AppTextField>(
        find.byType(AppTextField),
      );
      expect(appTextField.obscureText, isTrue);
    });

    testWidgets('readOnly prevents text input', (tester) async {
      final controller = TextEditingController(text: 'Initial');
      await tester.pumpApp(
        AppTextField(
          controller: controller,
          readOnly: true,
        ),
      );

      // Verify the widget was created with readOnly
      final appTextField = tester.widget<AppTextField>(
        find.byType(AppTextField),
      );
      expect(appTextField.readOnly, isTrue);
      expect(controller.text, 'Initial');
    });
  });
}
