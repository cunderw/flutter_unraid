import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';

class ContainerPortsSection extends StatelessWidget {
  final DockerContainer container;

  const ContainerPortsSection({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ports',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.unraidOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...container.ports.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lan_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      p.displayString,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (p.ip != null && p.ip!.isNotEmpty) ...[
                      const Spacer(),
                      Text(
                        p.ip!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
