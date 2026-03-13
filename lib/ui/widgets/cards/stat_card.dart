import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';

/// Compact card displaying a single stat value with label.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.mdl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.unraidOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: AppColors.unraidOrange,
                    ),
                  ),
                  AppSpacing.horizontalXs,
                ],
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            AppSpacing.verticalSm,
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
