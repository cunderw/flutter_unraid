import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/vms/vm_cubit.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/vm_domain.dart';

class VmActionsSection extends StatelessWidget {
  final VmDomain vm;

  const VmActionsSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VmCubit>();
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
                if (vm.isStopped)
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
                    onPressed: () => cubit.startVm(vm.id),
                    backgroundColor: AppColors.running.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: AppColors.running.withValues(alpha: 0.3),
                    ),
                  ),
                if (vm.isRunning)
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
                    onPressed: () => cubit.stopVm(vm.id),
                    backgroundColor: AppColors.stopped.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: AppColors.stopped.withValues(alpha: 0.3),
                    ),
                  ),
                if (vm.isRunning)
                  ActionChip(
                    avatar: const Icon(
                      Icons.pause,
                      size: 18,
                      color: AppColors.paused,
                    ),
                    label: const Text(
                      'Pause',
                      style: TextStyle(color: AppColors.paused),
                    ),
                    onPressed: () => cubit.pauseVm(vm.id),
                    backgroundColor: AppColors.paused.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: AppColors.paused.withValues(alpha: 0.3),
                    ),
                  ),
                if (vm.isPaused)
                  ActionChip(
                    avatar: const Icon(
                      Icons.play_arrow,
                      size: 18,
                      color: AppColors.running,
                    ),
                    label: const Text(
                      'Resume',
                      style: TextStyle(color: AppColors.running),
                    ),
                    onPressed: () => cubit.resumeVm(vm.id),
                    backgroundColor: AppColors.running.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: AppColors.running.withValues(alpha: 0.3),
                    ),
                  ),
                if (vm.isRunning)
                  ActionChip(
                    avatar: const Icon(
                      Icons.restart_alt,
                      size: 18,
                      color: AppColors.unraidOrange,
                    ),
                    label: const Text(
                      'Reboot',
                      style: TextStyle(color: AppColors.unraidOrange),
                    ),
                    onPressed: () => cubit.rebootVm(vm.id),
                    backgroundColor: AppColors.unraidOrange.withValues(
                      alpha: 0.1,
                    ),
                    side: BorderSide(
                      color: AppColors.unraidOrange.withValues(alpha: 0.3),
                    ),
                  ),
                if (vm.isRunning)
                  ActionChip(
                    avatar: const Icon(
                      Icons.power_settings_new,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    label: const Text(
                      'Force Stop',
                      style: TextStyle(color: AppColors.warning),
                    ),
                    onPressed: () => cubit.forceStopVm(vm.id),
                    backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: AppColors.warning.withValues(alpha: 0.3),
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
