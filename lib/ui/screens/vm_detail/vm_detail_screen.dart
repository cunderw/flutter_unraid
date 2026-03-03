import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/vms/vm_cubit.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/blocs/vms/vm_state.dart';
import 'package:flutter_unraid/data/models/vm_domain.dart';
import 'package:flutter_unraid/ui/screens/vm_detail/vm_actions_section.dart';
import 'package:flutter_unraid/ui/screens/vm_detail/vm_config_section.dart';
import 'package:flutter_unraid/ui/screens/vm_detail/vm_status_section.dart';

class VmDetailScreen extends StatelessWidget {
  final String vmId;

  const VmDetailScreen({super.key, required this.vmId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VmCubit, VmState>(
      builder: (context, state) {
        final vms = switch (state) {
          VmLoaded(:final vms) => vms,
          VmActionError(:final vms) => vms,
          _ => <VmDomain>[],
        };

        final vm = vms.where((v) => v.id == vmId).firstOrNull;

        return Scaffold(
          appBar: AppBar(
            title: Text(vm?.displayName ?? 'Virtual Machine'),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          body: vm == null
              ? Center(
                  child: Text(
                    'Virtual machine not found.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : VmDetailBody(vm: vm),
        );
      },
    );
  }
}

class VmDetailBody extends StatelessWidget {
  final VmDomain vm;

  const VmDetailBody({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        VmStatusSection(vm: vm),
        AppSpacing.verticalLg,
        VmConfigSection(vm: vm),
        AppSpacing.verticalLg,
        VmActionsSection(vm: vm),
      ],
    );
  }
}
