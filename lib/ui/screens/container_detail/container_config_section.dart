import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/ui/widgets/data_display/key_value_row.dart';

class ContainerConfigSection extends StatelessWidget {
  final DockerContainer container;

  const ContainerConfigSection({super.key, required this.container});

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
            KeyValueRow(label: 'Image', value: container.image),
            KeyValueRow(label: 'Image ID', value: container.imageId),
            KeyValueRow(label: 'Container ID', value: container.id),
            KeyValueRow(
              label: 'Auto Start',
              value: container.autoStart ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }
}
