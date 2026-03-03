import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/spacing.dart';

/// Row displaying a label-value pair.
class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const KeyValueRow({
    super.key,
    required this.label,
    this.value = '',
    this.valueWidget,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style:
                  labelStyle ??
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child:
                valueWidget ??
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      valueStyle ??
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
          ),
        ],
      ),
    );
  }
}
