import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/vms/vm_cubit.dart';
import 'package:flutter_unraid/blocs/vms/vm_state.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/vm_domain.dart';
import 'package:flutter_unraid/ui/widgets/cards/action_card.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';
import 'package:flutter_unraid/ui/widgets/feedback/confirmation_dialog.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_snackbar.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';
import 'package:flutter_unraid/ui/widgets/layout/section_header.dart';

class VmsTab extends StatelessWidget {
  const VmsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VmCubit, VmState>(
      listenWhen: (_, current) => current is VmActionError,
      listener: (context, state) {
        if (state is VmActionError) {
          showErrorSnackbar(context, message: state.message);
        }
      },
      child: BlocBuilder<VmCubit, VmState>(
        buildWhen: (_, current) => current is! VmActionError,
        builder: (context, state) {
          final vms = switch (state) {
            VmLoaded(:final vms) => vms,
            VmActionError(:final vms) => vms,
            _ => null,
          };

          if (state is VmInitial || state is VmLoading) {
            return const LoadingIndicator(
              message: 'Loading virtual machines...',
            );
          }

          if (state is VmError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () => context.read<VmCubit>().refresh(),
            );
          }

          if (vms == null || vms.isEmpty) {
            return const EmptyState(
              message: 'No virtual machines found.',
              icon: Icons.computer_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<VmCubit>().refresh(),
            color: AppColors.unraidOrange,
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              children: [
                SectionHeader(
                  title: 'Virtual Machines',
                  trailing: Text(
                    '${vms.where((v) => v.isRunning).length} running / ${vms.length} total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ...vms.map((vm) => _VmTile(vm: vm)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VmTile extends StatelessWidget {
  final VmDomain vm;

  const _VmTile({required this.vm});

  @override
  Widget build(BuildContext context) {
    return ActionCard(
      title: vm.displayName,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.computer,
          color: AppColors.unraidOrange,
          size: 18,
        ),
      ),
      actions: _buildActions(context),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxxs),
        child: StatusBadge.forVmState(vm.state),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final cubit = context.read<VmCubit>();
    return [
      if (vm.isStopped)
        _actionButton(
          context,
          icon: Icons.play_arrow,
          label: 'Start',
          color: AppColors.running,
          onPressed: () => cubit.startVm(vm.id),
        ),
      if (vm.isRunning) ...[
        _actionButton(
          context,
          icon: Icons.stop,
          label: 'Stop',
          color: AppColors.stopped,
          onPressed: () => cubit.stopVm(vm.id),
        ),
        _actionButton(
          context,
          icon: Icons.pause,
          label: 'Pause',
          color: AppColors.paused,
          onPressed: () => cubit.pauseVm(vm.id),
        ),
        _actionButton(
          context,
          icon: Icons.restart_alt,
          label: 'Reboot',
          color: AppColors.textSecondary,
          onPressed: () => cubit.rebootVm(vm.id),
        ),
        _moreActionsButton(context, cubit),
      ],
      if (vm.isPaused) ...[
        _actionButton(
          context,
          icon: Icons.play_arrow,
          label: 'Resume',
          color: AppColors.running,
          onPressed: () => cubit.resumeVm(vm.id),
        ),
        _moreActionsButton(context, cubit),
      ],
    ];
  }

  Future<void> _confirmForceStop(BuildContext context, VmCubit cubit) async {
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

  Widget _moreActionsButton(BuildContext context, VmCubit cubit) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 16,
        color: AppColors.textSecondary,
      ),
      iconSize: 16,
      padding: EdgeInsets.zero,
      tooltip: 'More actions',
      offset: const Offset(0, 32),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'force_stop',
          child: Row(
            children: [
              Icon(
                Icons.dangerous_outlined,
                size: 18,
                color: AppColors.stopped,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Force Stop',
                style: TextStyle(color: AppColors.stopped, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'force_stop') {
          _confirmForceStop(context, cubit);
        }
      },
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
