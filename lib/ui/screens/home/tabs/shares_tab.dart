import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/shares/shares_cubit.dart';
import 'package:flutter_unraid/blocs/shares/shares_state.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/share.dart';
import 'package:flutter_unraid/ui/widgets/cards/info_card.dart';
import 'package:flutter_unraid/ui/widgets/data_display/usage_bar.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';
import 'package:flutter_unraid/ui/widgets/layout/section_header.dart';
import 'package:flutter_unraid/utils/formatters.dart';

class SharesTab extends StatelessWidget {
  const SharesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharesCubit, SharesState>(
      builder: (context, state) => switch (state) {
        SharesInitial() ||
        SharesLoading() => const LoadingIndicator(message: 'Loading shares...'),
        SharesError(:final message) => ErrorDisplay(
          message: message,
          onRetry: () => context.read<SharesCubit>().refresh(),
        ),
        SharesLoaded(:final shares) =>
          shares.isEmpty
              ? const EmptyState(
                  message: 'No shares found.',
                  icon: Icons.folder_shared_outlined,
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<SharesCubit>().refresh(),
                  color: AppColors.unraidOrange,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    children: [
                      SectionHeader(
                        title: 'Shares',
                        trailing: Text(
                          '${shares.length} total',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      ...shares.map((s) => _ShareTile(share: s)),
                    ],
                  ),
                ),
      },
    );
  }
}

class _ShareTile extends StatelessWidget {
  final Share share;

  const _ShareTile({required this.share});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: share.displayName,
      leading: const Icon(
        Icons.folder,
        color: AppColors.unraidOrange,
        size: 20,
      ),
      trailing: share.cache == true
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.paused.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cached',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.paused),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (share.comment != null && share.comment!.isNotEmpty) ...[
            Text(
              share.comment!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalMd,
          ],
          UsageBar(
            percentage: share.usagePercent,
            label: '${(share.usagePercent * 100).toStringAsFixed(1)}% used',
            detail:
                '${Formatters.formatKilobytes(share.used)} / ${Formatters.formatKilobytes(share.size)}',
          ),
        ],
      ),
    );
  }
}
