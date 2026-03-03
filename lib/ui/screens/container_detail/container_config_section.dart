import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/ui/screens/webview/webview_screen.dart';
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
            if (container.webUiUrl != null)
              KeyValueRow(
                label: 'Web UI',
                valueWidget: GestureDetector(
                  onTap: () => WebViewScreen.open(
                    context,
                    url: container.webUiUrl!,
                    title: container.displayName,
                  ),
                  child: Text(
                    container.webUiUrl!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.unraidOrange,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.unraidOrange,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
