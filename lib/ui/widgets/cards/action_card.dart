import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/theme.dart';

/// Card with primary and optional secondary actions.
class ActionCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onTap;

  const ActionCard({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.actions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              if (title != null) const SizedBox(height: 12),
              child,
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:
                      actions!
                          .expand((a) => [a, const SizedBox(width: 8)])
                          .toList()
                        ..removeLast(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
