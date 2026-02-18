import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/config/theme.dart';

extension PumpHelpers on WidgetTester {
  /// Pumps [widget] wrapped in a [MaterialApp] with the Unraid dark theme.
  Future<void> pumpApp(Widget widget) async {
    await pumpWidget(
      MaterialApp(
        theme: unraidDarkTheme,
        home: Scaffold(body: widget),
      ),
    );
  }

  /// Pumps [widget] wrapped in a [MaterialApp] with [BlocProvider]s.
  Future<void> pumpAppWithBlocs(
    Widget widget, {
    required List<BlocProvider> providers,
  }) async {
    await pumpWidget(
      MaterialApp(
        theme: unraidDarkTheme,
        home: MultiBlocProvider(
          providers: providers,
          child: Scaffold(body: widget),
        ),
      ),
    );
  }
}
