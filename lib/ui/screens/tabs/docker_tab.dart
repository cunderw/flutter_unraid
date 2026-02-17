import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
import 'package:flutter_unraid/blocs/docker/docker_state.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';
import 'package:flutter_unraid/ui/widgets/feedback/confirmation_dialog.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';
import 'package:flutter_unraid/ui/widgets/layout/section_header.dart';

class DockerTab extends StatelessWidget {
  const DockerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DockerCubit, DockerState>(
      builder: (context, state) => switch (state) {
        DockerInitial() || DockerLoading() => const LoadingIndicator(
          message: 'Loading containers...',
        ),
        DockerError(:final message) => ErrorDisplay(
          message: message,
          onRetry: () => context.read<DockerCubit>().refresh(),
        ),
        DockerLoaded(:final containers) =>
          containers.isEmpty
              ? const EmptyState(
                  message: 'No Docker containers found.',
                  icon: Icons.inventory_2_outlined,
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<DockerCubit>().refresh(),
                  color: AppColors.unraidOrange,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      SectionHeader(
                        title: 'Containers',
                        trailing: Text(
                          '${(state).running} running / ${containers.length} total',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      ...containers.map((c) => _ContainerTile(container: c)),
                    ],
                  ),
                ),
      },
    );
  }
}

class _ContainerTile extends StatelessWidget {
  final DockerContainer container;

  const _ContainerTile({required this.container});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildIcon(),
        title: Text(
          container.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              container.image,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            StatusBadge.forContainerState(container.state),
          ],
        ),
        trailing: _buildActions(context),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.inventory_2, color: AppColors.unraidOrange),
    );
  }

  Widget _buildActions(BuildContext context) {
    final cubit = context.read<DockerCubit>();
    return PopupMenuButton<String>(
      onSelected: (action) => _handleAction(context, cubit, action),
      itemBuilder: (context) => [
        if (container.isStopped)
          const PopupMenuItem(value: 'start', child: Text('Start')),
        if (container.isRunning)
          const PopupMenuItem(value: 'stop', child: Text('Stop')),
        if (container.isRunning)
          const PopupMenuItem(value: 'pause', child: Text('Pause')),
        if (container.isPaused)
          const PopupMenuItem(value: 'unpause', child: Text('Unpause')),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'remove',
          child: Text('Remove', style: TextStyle(color: AppColors.stopped)),
        ),
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    DockerCubit cubit,
    String action,
  ) async {
    switch (action) {
      case 'start':
        await cubit.startContainer(container.id);
      case 'stop':
        await cubit.stopContainer(container.id);
      case 'pause':
        await cubit.pauseContainer(container.id);
      case 'unpause':
        await cubit.unpauseContainer(container.id);
      case 'remove':
        if (!context.mounted) return;
        final confirmed = await showConfirmationDialog(
          context,
          title: 'Remove Container',
          message:
              'Are you sure you want to remove "${container.displayName}"?',
          confirmLabel: 'Remove',
          isDestructive: true,
        );
        if (confirmed) {
          await cubit.removeContainer(container.id);
        }
    }
  }
}
