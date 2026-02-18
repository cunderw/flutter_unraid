import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';

class ContainerActionsSection extends StatelessWidget {
  final DockerContainer container;

  const ContainerActionsSection({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DockerCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.unraidOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalMd,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (container.isStopped)
                  ActionChip(
                    avatar: const Icon(
                      Icons.play_arrow,
                      size: 18,
                      color: AppColors.running,
                    ),
                    label: const Text(
                      'Start',
                      style: TextStyle(color: AppColors.running),
                    ),
                    onPressed: () => cubit.startContainer(container.id),
                    backgroundColor: AppColors.running.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: AppColors.running.withValues(alpha: 0.3),
                    ),
                  ),
                if (container.isRunning)
                  ActionChip(
                    avatar: const Icon(
                      Icons.stop,
                      size: 18,
                      color: AppColors.stopped,
                    ),
                    label: const Text(
                      'Stop',
                      style: TextStyle(color: AppColors.stopped),
                    ),
                    onPressed: () => cubit.stopContainer(container.id),
                    backgroundColor: AppColors.stopped.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: AppColors.stopped.withValues(alpha: 0.3),
                    ),
                  ),
                if (container.isRunning)
                  ActionChip(
                    avatar: const Icon(
                      Icons.restart_alt,
                      size: 18,
                      color: AppColors.unraidOrange,
                    ),
                    label: const Text(
                      'Restart',
                      style: TextStyle(color: AppColors.unraidOrange),
                    ),
                    onPressed: () => cubit.restartContainer(container.id),
                    backgroundColor: AppColors.unraidOrange.withValues(
                      alpha: 0.1,
                    ),
                    side: BorderSide(
                      color: AppColors.unraidOrange.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
