import 'package:flutter/material.dart';

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

  Color get _color {
    if (barColor != null) return barColor!;
    if (percentage > 0.9) return AppColors.stopped;
    if (percentage > 0.75) return AppColors.warning;
    return AppColors.running;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || detail != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (detail != null)
                  Text(
                    detail!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
      ],
    );
  }
}
