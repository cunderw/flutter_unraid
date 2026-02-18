import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';

/// Compact inline error message with optional retry, suitable for embedding
/// within cards or sections (as opposed to [ErrorDisplay] which is full-page).
class InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineError({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.stopped.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stopped.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.stopped, size: 18),
          AppSpacing.horizontalSm,
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.stopped),
            ),
          ),
          if (onRetry != null) ...[
            AppSpacing.horizontalSm,
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              color: AppColors.stopped,
              onPressed: onRetry,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Retry',
            ),
          ],
        ],
      ),
    );
  }
}
