import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';

class ContainerConfigSection extends StatelessWidget {
  final DockerContainer container;

  const ContainerConfigSection({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            _configRow(context, 'Image', container.image),
            _configRow(context, 'Image ID', _truncateId(container.imageId)),
            _configRow(context, 'Container ID', _truncateId(container.id)),
            _configRow(
              context,
              'Auto Start',
              container.autoStart ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }

  String _truncateId(String id) {
    if (id.length > 12) return '${id.substring(0, 12)}…';
    return id;
  }

  Widget _configRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
