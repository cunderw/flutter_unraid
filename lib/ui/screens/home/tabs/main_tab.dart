import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/system/system_cubit.dart';
import 'package:flutter_unraid/blocs/system/system_state.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/array_data.dart';
import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:flutter_unraid/di/injection.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/cubit/system_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/system_logs_section.dart';
import 'package:flutter_unraid/ui/widgets/cards/info_card.dart';
import 'package:flutter_unraid/ui/widgets/cards/stat_card.dart';
import 'package:flutter_unraid/ui/widgets/data_display/key_value_row.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';
import 'package:flutter_unraid/ui/widgets/data_display/usage_bar.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_snackbar.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';
import 'package:flutter_unraid/ui/widgets/layout/collapsible_section.dart';
import 'package:flutter_unraid/utils/formatters.dart';

class MainTab extends StatefulWidget {
  const MainTab({super.key});

  @override
  State<MainTab> createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  bool _isOverviewExpanded = true;
  bool _isSystemExpanded = true;
  bool _isArrayExpanded = false;
  bool _isDisksExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SystemCubit, SystemState>(
      listenWhen: (_, current) => current is SystemActionError,
      listener: (context, state) {
        if (state is SystemActionError) {
          showErrorSnackbar(context, message: state.message);
        }
      },
      child: BlocBuilder<SystemCubit, SystemState>(
        buildWhen: (_, current) => current is! SystemActionError,
        builder: (context, state) => switch (state) {
          SystemInitial() || SystemLoading() => const LoadingIndicator(
            message: 'Loading system info...',
          ),
          SystemError(:final message) => ErrorDisplay(
            message: message,
            onRetry: () => context.read<SystemCubit>().refresh(),
          ),
          SystemLoaded(:final systemInfo, :final memory, :final arrayData) ||
          SystemActionError(
            :final systemInfo,
            :final memory,
            :final arrayData,
          ) => RefreshIndicator(
            onRefresh: () => context.read<SystemCubit>().refresh(),
            color: AppColors.unraidOrange,
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              children: [
                // ── Quick Stats ──────────────────────────
                CollapsibleSection(
                  title: 'Overview',
                  isExpanded: _isOverviewExpanded,
                  onToggle: () => setState(() {
                    _isOverviewExpanded = !_isOverviewExpanded;
                  }),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Uptime',
                              value: Formatters.formatUptime(
                                systemInfo.os?.uptime,
                              ),
                              icon: Icons.timer_outlined,
                            ),
                          ),
                          Expanded(
                            child: StatCard(
                              label: 'Memory',
                              value: memory?.percentTotal != null
                                  ? '${memory!.percentTotal!.toStringAsFixed(1)}%'
                                  : '--',
                              icon: Icons.memory,
                              valueColor: (memory?.percentTotal ?? 0) > 80
                                  ? AppColors.warning
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Array',
                              value: arrayData.state.toUpperCase(),
                              icon: Icons.storage,
                              valueColor: AppColors.forArrayState(
                                arrayData.state,
                              ),
                            ),
                          ),
                          Expanded(
                            child: StatCard(
                              label: 'Disks',
                              value: '${arrayData.disks.length}',
                              icon: Icons.disc_full_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── System Detail ────────────────────────
                CollapsibleSection(
                  title: 'System',
                  isExpanded: _isSystemExpanded,
                  onToggle: () => setState(() {
                    _isSystemExpanded = !_isSystemExpanded;
                  }),
                  children: [
                    InfoCard(
                      title: 'Server Info',
                      leading: const Icon(
                        Icons.dns,
                        color: AppColors.unraidOrange,
                      ),
                      child: Column(
                        children: [
                          KeyValueRow(
                            label: 'OS',
                            value:
                                '${systemInfo.os?.distro ?? 'Unknown'} ${systemInfo.os?.release ?? ''}',
                          ),
                          KeyValueRow(
                            label: 'Uptime',
                            value: Formatters.formatUptime(
                              systemInfo.os?.uptime,
                            ),
                          ),
                          KeyValueRow(
                            label: 'CPU',
                            value: systemInfo.cpu?.brand ?? 'Unknown',
                          ),
                          KeyValueRow(
                            label: 'Cores / Threads',
                            value:
                                '${systemInfo.cpu?.cores ?? '-'} / ${systemInfo.cpu?.threads ?? '-'}',
                          ),
                        ],
                      ),
                    ),

                    // ── Memory ───────────────────────────────
                    InfoCard(
                      title: 'Memory',
                      leading: const Icon(
                        Icons.memory,
                        color: AppColors.unraidOrange,
                      ),
                      child: Column(
                        children: [
                          UsageBar(
                            percentage: Formatters.usagePercent(
                              memory?.used,
                              memory?.total,
                            ),
                            label: 'Used',
                            detail:
                                '${Formatters.formatBytes(memory?.used)} / ${Formatters.formatBytes(memory?.total)}',
                          ),
                        ],
                      ),
                    ),

                    BlocProvider(
                      create: (_) => SystemLogsCubit(getIt<SystemRepository>()),
                      child: const SystemLogsSection(),
                    ),
                  ],
                ),

                // ── Array ────────────────────────────────
                CollapsibleSection(
                  title: 'Array',
                  isExpanded: _isArrayExpanded,
                  onToggle: () => setState(() {
                    _isArrayExpanded = !_isArrayExpanded;
                  }),
                  children: [
                    InfoCard(
                      title: 'Array Status',
                      leading: const Icon(
                        Icons.storage,
                        color: AppColors.unraidOrange,
                      ),
                      trailing: StatusBadge.forArrayState(arrayData.state),
                      child: Column(
                        children: [
                          if (arrayData.capacity?.kilobytes != null) ...[
                            UsageBar(
                              percentage: Formatters.usagePercent(
                                num.tryParse(
                                  arrayData.capacity!.kilobytes!.used,
                                ),
                                num.tryParse(
                                  arrayData.capacity!.kilobytes!.total,
                                ),
                              ),
                              label: 'Storage',
                              detail:
                                  '${Formatters.formatKilobytes(num.tryParse(arrayData.capacity!.kilobytes!.used))} / ${Formatters.formatKilobytes(num.tryParse(arrayData.capacity!.kilobytes!.total))}',
                            ),
                            AppSpacing.verticalMd,
                          ],
                          KeyValueRow(
                            label: 'Data Disks',
                            value: '${arrayData.disks.length}',
                          ),
                          KeyValueRow(
                            label: 'Parity',
                            value: '${arrayData.parities.length}',
                          ),
                          KeyValueRow(
                            label: 'Cache',
                            value: '${arrayData.caches.length}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Disk List ────────────────────────────
                if (arrayData.disks.isNotEmpty)
                  CollapsibleSection(
                    title: 'Disks',
                    isExpanded: _isDisksExpanded,
                    onToggle: () => setState(() {
                      _isDisksExpanded = !_isDisksExpanded;
                    }),
                    children: arrayData.disks
                        .map(
                          (disk) => InfoCard(
                            title: disk.displayName,
                            onTap: () => _showDiskDetails(context, disk),
                            trailing: disk.temp != null
                                ? Text(
                                    Formatters.formatTemperature(disk.temp),
                                    style: TextStyle(
                                      color: (disk.temp ?? 0) > 45
                                          ? AppColors.warning
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                : null,
                            child: Column(
                              children: [
                                UsageBar(
                                  percentage: disk.usagePercent,
                                  label: disk.status ?? '',
                                  detail:
                                      '${Formatters.formatKilobytes(disk.fsUsed)} / ${Formatters.formatKilobytes(disk.fsSize)}',
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        },
      ),
    );
  }

  void _showDiskDetails(BuildContext context, ArrayDisk disk) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) =>
            _DiskDetailSheet(disk: disk, scrollController: scrollController),
      ),
    );
  }
}

class _DiskDetailSheet extends StatelessWidget {
  final ArrayDisk disk;
  final ScrollController scrollController;

  const _DiskDetailSheet({
    required this.disk,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = AppColors.forDiskStatus(disk.status);

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
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.storage,
                  color: statusColor,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disk.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (disk.device != null)
                      Text(
                        disk.device!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
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
              // Usage bar
              UsageBar(
                percentage: disk.usagePercent,
                label: '${(disk.usagePercent * 100).toStringAsFixed(1)}% used',
                detail:
                    '${Formatters.formatKilobytes(disk.fsUsed)} / ${Formatters.formatKilobytes(disk.fsSize)}',
                height: 10,
              ),
              AppSpacing.verticalXl,
              // Details
              if (disk.status != null)
                KeyValueRow(label: 'Status', value: disk.status!),
              if (disk.type != null)
                KeyValueRow(label: 'Type', value: disk.type!),
              if (disk.fsType != null)
                KeyValueRow(label: 'Filesystem', value: disk.fsType!),
              if (disk.temp != null)
                KeyValueRow(
                  label: 'Temperature',
                  value: Formatters.formatTemperature(disk.temp),
                  valueStyle: TextStyle(
                    color: (disk.temp ?? 0) > 45
                        ? AppColors.warning
                        : colorScheme.onSurface,
                  ),
                ),
              if (disk.numReads != null)
                KeyValueRow(
                  label: 'Reads',
                  value: disk.numReads!.toString(),
                ),
              if (disk.numWrites != null)
                KeyValueRow(
                  label: 'Writes',
                  value: disk.numWrites!.toString(),
                ),
              if (disk.numErrors != null && disk.numErrors! > 0)
                KeyValueRow(
                  label: 'Errors',
                  value: disk.numErrors!.toString(),
                  valueStyle: const TextStyle(color: AppColors.stopped),
                ),
              if (disk.comment != null && disk.comment!.isNotEmpty)
                KeyValueRow(label: 'Comment', value: disk.comment!),
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
