import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/shares/shares_cubit.dart';
import 'package:flutter_unraid/blocs/shares/shares_state.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/share.dart';
import 'package:flutter_unraid/ui/widgets/cards/info_card.dart';
import 'package:flutter_unraid/ui/widgets/data_display/key_value_row.dart';
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

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _ShareDetailSheet(
          share: share,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: share.displayName,
      onTap: () => _showDetails(context),
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
                '${Formatters.formatKilobytes(share.used)} / ${Formatters.formatKilobytes(share.free)}',
          ),
        ],
      ),
    );
  }
}

class _ShareDetailSheet extends StatelessWidget {
  final Share share;
  final ScrollController scrollController;

  const _ShareDetailSheet({
    required this.share,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.unraidOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.folder,
                  color: AppColors.unraidOrange,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Text(
                  share.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Scrollable content
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            children: [
              // Storage usage
              UsageBar(
                percentage: share.usagePercent,
                label: '${(share.usagePercent * 100).toStringAsFixed(1)}% used',
                detail:
                    '${Formatters.formatKilobytes(share.used)} / ${Formatters.formatKilobytes(share.free)}',
                height: 10,
              ),
              AppSpacing.verticalXl,
              // Details
              if (share.comment != null && share.comment!.isNotEmpty) ...[
                KeyValueRow(label: 'Comment', value: share.comment!),
              ],
              KeyValueRow(
                label: 'Cache',
                value: share.cache == true ? 'Enabled' : 'Disabled',
              ),
              if (share.allocator != null)
                KeyValueRow(label: 'Allocator', value: share.allocator!),
              if (share.splitLevel != null)
                KeyValueRow(label: 'Split Level', value: share.splitLevel!),
              if (share.floor != null && share.floor!.isNotEmpty)
                KeyValueRow(label: 'Min Free Space', value: share.floor!),
              if (share.cow != null)
                KeyValueRow(label: 'Copy on Write', value: share.cow!),
              if (share.luksStatus != null && share.luksStatus!.isNotEmpty)
                KeyValueRow(label: 'LUKS Status', value: share.luksStatus!),
              if (share.include != null && share.include!.isNotEmpty) ...[
                AppSpacing.verticalMd,
                Text(
                  'Included Disks',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                AppSpacing.verticalXs,
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: share.include!
                      .map(
                        (d) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            d,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (share.exclude != null && share.exclude!.isNotEmpty) ...[
                AppSpacing.verticalMd,
                Text(
                  'Excluded Disks',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                AppSpacing.verticalXs,
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: share.exclude!
                      .map(
                        (d) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.stopped.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            d,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: AppColors.stopped,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              // Bottom padding for safe area
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
