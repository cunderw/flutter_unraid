import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';

/// Horizontal bar showing usage percentage with label.
class UsageBar extends StatelessWidget {
  final double percentage; // 0.0 - 1.0
  final String? label;
  final String? detail;
  final Color? barColor;
  final double height;

  const UsageBar({
    super.key,
    required this.percentage,
    this.label,
    this.detail,
    this.barColor,
    this.height = 8,
  });

  Color _resolveColor(double pct) {
    if (barColor != null) return barColor!;
    if (pct > 0.9) return AppColors.stopped;
    if (pct > 0.75) return AppColors.warning;
    return AppColors.running;
  }

  @override
  Widget build(BuildContext context) {
    final clampedPct = percentage.clamp(0.0, 1.0);
    final trackColor = Theme.of(context).dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || detail != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (detail != null)
                  Text(
                    detail!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: clampedPct),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          builder: (context, value, _) {
            final color = _resolveColor(value);
            return SizedBox(
              height: height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        width: constraints.maxWidth,
                        height: height,
                        decoration: BoxDecoration(
                          color: trackColor,
                          borderRadius: BorderRadius.circular(height / 2),
                        ),
                      ),
                      if (value > 0)
                        Container(
                          width: constraints.maxWidth * value,
                          height: height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color.withValues(alpha: 0.75), color],
                            ),
                            borderRadius: BorderRadius.circular(height / 2),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
