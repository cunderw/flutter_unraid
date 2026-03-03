import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/ui/widgets/data_display/container_icon.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';

class ContainerStatusSection extends StatelessWidget {
  final DockerContainer container;

  const ContainerStatusSection({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            ContainerIcon(
              iconUrl: container.iconUrl,
              size: 48,
              iconSize: 28,
              borderRadius: 12,
            ),
            AppSpacing.horizontalLg,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    container.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalXxs,
                  Text(
                    container.status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge.forContainerState(container.state),
          ],
        ),
      ),
    );
  }
}
