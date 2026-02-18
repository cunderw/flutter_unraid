import 'package:flutter/material.dart';

/// Consistent spacing constants used throughout the app.
///
/// Based on a 4-point grid with intermediate values where needed.
abstract final class AppSpacing {
  // ── Raw values ─────────────────────────────────────────────────────────

  /// 2.0
  static const double xxxs = 2;

  /// 4.0
  static const double xxs = 4;

  /// 6.0
  static const double xs = 6;

  /// 8.0
  static const double sm = 8;

  /// 10.0
  static const double smd = 10;

  /// 12.0
  static const double md = 12;

  /// 14.0
  static const double mdl = 14;

  /// 16.0
  static const double lg = 16;

  /// 20.0
  static const double xl = 20;

  /// 24.0
  static const double xxl = 24;

  /// 32.0
  static const double xxxl = 32;

  /// 48.0
  static const double xxxxl = 48;

  // ── Vertical gaps (SizedBox) ───────────────────────────────────────────

  static const Widget verticalXxxs = SizedBox(height: xxxs);
  static const Widget verticalXxs = SizedBox(height: xxs);
  static const Widget verticalXs = SizedBox(height: xs);
  static const Widget verticalSm = SizedBox(height: sm);
  static const Widget verticalMd = SizedBox(height: md);
  static const Widget verticalLg = SizedBox(height: lg);
  static const Widget verticalXl = SizedBox(height: xl);
  static const Widget verticalXxl = SizedBox(height: xxl);
  static const Widget verticalXxxl = SizedBox(height: xxxl);
  static const Widget verticalXxxxl = SizedBox(height: xxxxl);

  // ── Horizontal gaps (SizedBox) ─────────────────────────────────────────

  static const Widget horizontalXxxs = SizedBox(width: xxxs);
  static const Widget horizontalXxs = SizedBox(width: xxs);
  static const Widget horizontalXs = SizedBox(width: xs);
  static const Widget horizontalSm = SizedBox(width: sm);
  static const Widget horizontalMd = SizedBox(width: md);
  static const Widget horizontalLg = SizedBox(width: lg);
  static const Widget horizontalXl = SizedBox(width: xl);
}
