import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/shares/shares_cubit.dart';
import 'package:flutter_unraid/blocs/shares/shares_state.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/share.dart';
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
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      SectionHeader(
                        title: 'Shares',
                        trailing: Text(
                          '${shares.length} total',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.folder,
                  color: AppColors.unraidOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    share.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (share.cache == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
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
                  ),
              ],
            ),
            if (share.comment != null && share.comment!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                share.comment!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            UsageBar(
              percentage: share.usagePercent,
              label: '${(share.usagePercent * 100).toStringAsFixed(1)}% used',
              detail:
                  '${Formatters.formatKilobytes(share.used)} / ${Formatters.formatKilobytes(share.size)}',
            ),
          ],
        ),
      ),
    );
  }
}
