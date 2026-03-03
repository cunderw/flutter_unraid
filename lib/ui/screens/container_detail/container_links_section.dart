import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/ui/screens/webview/webview_screen.dart';

class ContainerLinksSection extends StatelessWidget {
  final DockerContainer container;

  const ContainerLinksSection({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Links',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.unraidOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalMd,
            if (container.projectUrl != null)
              _LinkRow(
                icon: Icons.code,
                label: 'Project',
                url: container.projectUrl!,
              ),
            if (container.supportUrl != null)
              _LinkRow(
                icon: Icons.help_outline,
                label: 'Support',
                url: container.supportUrl!,
              ),
            if (container.registryUrl != null)
              _LinkRow(
                icon: Icons.cloud_outlined,
                label: 'Registry',
                url: container.registryUrl!,
              ),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _LinkRow({required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: InkWell(
        onTap: () => WebViewScreen.open(context, url: url, title: label),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              AppSpacing.horizontalSm,
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Text(
                  url,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.unraidOrange,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.unraidOrange,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpacing.horizontalSm,
              const Icon(
                Icons.open_in_new,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
