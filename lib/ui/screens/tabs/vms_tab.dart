import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/vms/vm_cubit.dart';
import 'package:flutter_unraid/blocs/vms/vm_state.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/vm_domain.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';
import 'package:flutter_unraid/ui/widgets/feedback/confirmation_dialog.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';
import 'package:flutter_unraid/ui/widgets/layout/section_header.dart';

class VmsTab extends StatelessWidget {
  const VmsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VmCubit, VmState>(
      builder: (context, state) => switch (state) {
        VmInitial() || VmLoading() => const LoadingIndicator(
          message: 'Loading virtual machines...',
        ),
        VmError(:final message) => ErrorDisplay(
          message: message,
          onRetry: () => context.read<VmCubit>().refresh(),
        ),
        VmLoaded(:final vms) =>
          vms.isEmpty
              ? const EmptyState(
                  message: 'No virtual machines found.',
                  icon: Icons.computer_outlined,
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<VmCubit>().refresh(),
                  color: AppColors.unraidOrange,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      SectionHeader(
                        title: 'Virtual Machines',
                        trailing: Text(
                          '${(state).running} running / ${vms.length} total',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      ...vms.map((vm) => _VmTile(vm: vm)),
                    ],
                  ),
                ),
      },
    );
  }
}

class _VmTile extends StatelessWidget {
  final VmDomain vm;

  const _VmTile({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.computer, color: AppColors.unraidOrange),
        ),
        title: Text(
          vm.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: StatusBadge.forVmState(vm.state),
        ),
        trailing: _buildActions(context),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final cubit = context.read<VmCubit>();
    return PopupMenuButton<String>(
      onSelected: (action) => _handleAction(context, cubit, action),
      itemBuilder: (context) => [
        if (vm.isStopped)
          const PopupMenuItem(value: 'start', child: Text('Start')),
        if (vm.isRunning) ...[
          const PopupMenuItem(value: 'stop', child: Text('Shutdown')),
          const PopupMenuItem(value: 'pause', child: Text('Pause')),
          const PopupMenuItem(value: 'reboot', child: Text('Reboot')),
        ],
        if (vm.isPaused)
          const PopupMenuItem(value: 'resume', child: Text('Resume')),
        if (vm.isRunning || vm.isPaused) ...[
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'forceStop',
            child: Text(
              'Force Stop',
              style: TextStyle(color: AppColors.stopped),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    VmCubit cubit,
    String action,
  ) async {
    switch (action) {
      case 'start':
        await cubit.startVm(vm.id);
      case 'stop':
        await cubit.stopVm(vm.id);
      case 'pause':
        await cubit.pauseVm(vm.id);
      case 'resume':
        await cubit.resumeVm(vm.id);
      case 'reboot':
        await cubit.rebootVm(vm.id);
      case 'forceStop':
        if (!context.mounted) return;
        final confirmed = await showConfirmationDialog(
          context,
          title: 'Force Stop VM',
          message:
              'Are you sure you want to force stop "${vm.displayName}"? Unsaved data may be lost.',
          confirmLabel: 'Force Stop',
          isDestructive: true,
        );
        if (confirmed) {
          await cubit.forceStopVm(vm.id);
        }
    }
  }
}
