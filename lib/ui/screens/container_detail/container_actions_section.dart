import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
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
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (container.isStopped)
                  _actionChip(
                    context,
                    icon: Icons.play_arrow,
                    label: 'Start',
                    color: AppColors.running,
                    onPressed: () => cubit.startContainer(container.id),
                  ),
                if (container.isRunning)
                  _actionChip(
                    context,
                    icon: Icons.stop,
                    label: 'Stop',
                    color: AppColors.stopped,
                    onPressed: () => cubit.stopContainer(container.id),
                  ),
                if (container.isRunning)
                  _actionChip(
                    context,
                    icon: Icons.restart_alt,
                    label: 'Restart',
                    color: AppColors.unraidOrange,
                    onPressed: () => cubit.restartContainer(container.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      onPressed: onPressed,
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }
}
