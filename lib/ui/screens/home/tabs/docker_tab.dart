import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
import 'package:flutter_unraid/blocs/docker/docker_state.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_detail_screen.dart';
import 'package:flutter_unraid/ui/widgets/cards/action_card.dart';
import 'package:flutter_unraid/ui/widgets/data_display/container_icon.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_snackbar.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';
import 'package:flutter_unraid/ui/widgets/layout/section_header.dart';
import 'package:flutter_unraid/utils/url_helper.dart';

class DockerTab extends StatelessWidget {
  const DockerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DockerCubit, DockerState>(
      listenWhen: (_, current) => current is DockerActionError,
      listener: (context, state) {
        if (state is DockerActionError) {
          showErrorSnackbar(context, message: state.message);
        }
      },
      child: BlocBuilder<DockerCubit, DockerState>(
        buildWhen: (_, current) => current is! DockerActionError,
        builder: (context, state) {
          final containers = switch (state) {
            DockerLoaded(:final containers) => containers,
            DockerActionError(:final containers) => containers,
            _ => null,
          };

          if (state is DockerInitial || state is DockerLoading) {
            return const LoadingIndicator(message: 'Loading containers...');
          }

          if (state is DockerError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () => context.read<DockerCubit>().refresh(),
            );
          }

          if (containers == null || containers.isEmpty) {
            return const EmptyState(
              message: 'No Docker containers found.',
              icon: Icons.inventory_2_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<DockerCubit>().refresh(),
            color: AppColors.unraidOrange,
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              children: [
                SectionHeader(
                  title: 'Containers',
                  trailing: Text(
                    '${containers.where((c) => c.isRunning).length} running / ${containers.length} total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ...containers.map((c) => _ContainerTile(container: c)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContainerTile extends StatelessWidget {
  final DockerContainer container;

  const _ContainerTile({required this.container});

  @override
  Widget build(BuildContext context) {
    return ActionCard(
      title: container.displayName,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: context.read<DockerCubit>(),
              child: ContainerDetailScreen(containerId: container.id),
            ),
          ),
        );
      },
      leading: ContainerIcon(
        iconUrl: container.iconUrl,
        size: 32,
        iconSize: 18,
        borderRadius: 8,
      ),
      actions: _buildActions(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            container.image,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.verticalSm,
          StatusBadge.forContainerState(container.state),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final cubit = context.read<DockerCubit>();
    return [
      if (container.webUiUrl != null)
        _actionButton(
          context,
          icon: Icons.open_in_new,
          label: 'Web UI',
          color: AppColors.unraidOrange,
          onPressed: () => openUrl(
            context,
            url: container.webUiUrl!,
            title: container.displayName,
          ),
        ),
      if (container.isStopped)
        _actionButton(
          context,
          icon: Icons.play_arrow,
          label: 'Start',
          color: AppColors.running,
          onPressed: () => cubit.startContainer(container.id),
        ),
      if (container.isRunning)
        _actionButton(
          context,
          icon: Icons.stop,
          label: 'Stop',
          color: AppColors.stopped,
          onPressed: () => cubit.stopContainer(container.id),
        ),
      if (container.isRunning)
        _actionButton(
          context,
          icon: Icons.restart_alt,
          label: 'Restart',
          color: AppColors.unraidOrange,
          onPressed: () => cubit.restartContainer(container.id),
        ),
    ];
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
