import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/vm_domain.dart';
import 'package:flutter_unraid/ui/widgets/data_display/key_value_row.dart';

class VmConfigSection extends StatelessWidget {
  final VmDomain vm;

  const VmConfigSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.unraidOrange,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalMd,
            KeyValueRow(label: 'VM ID', value: vm.id),
            if (vm.cpus != null)
              KeyValueRow(label: 'CPUs', value: vm.cpus.toString()),
            if (vm.memory != null)
              KeyValueRow(label: 'Memory', value: vm.memoryDisplay),
            if (vm.autostart != null)
              KeyValueRow(
                label: 'Auto Start',
                value: vm.autostart! ? 'Yes' : 'No',
              ),
            if (vm.template != null)
              KeyValueRow(label: 'Template', value: vm.template!),
            if (vm.description != null && vm.description!.isNotEmpty)
              KeyValueRow(label: 'Description', value: vm.description!),
          ],
        ),
      ),
    );
  }
}
