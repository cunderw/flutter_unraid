import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/blocs/docker/docker_state.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_actions_section.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_config_section.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_logs_section.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_ports_section.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_status_section.dart';

class ContainerDetailScreen extends StatelessWidget {
  final String containerId;

  const ContainerDetailScreen({super.key, required this.containerId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DockerCubit, DockerState>(
      builder: (context, state) {
        final containers = switch (state) {
          DockerLoaded(:final containers) => containers,
          DockerActionError(:final containers) => containers,
          _ => <DockerContainer>[],
        };

        final container = containers
            .where((c) => c.id == containerId)
            .firstOrNull;

        return Scaffold(
          appBar: AppBar(
            title: Text(container?.displayName ?? 'Container'),
            backgroundColor: AppColors.surface,
          ),
          body: container == null
              ? const Center(
                  child: Text(
                    'Container not found.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ContainerDetailBody(container: container),
        );
      },
    );
  }
}

class ContainerDetailBody extends StatelessWidget {
  final DockerContainer container;

  const ContainerDetailBody({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ContainerStatusSection(container: container),
        AppSpacing.verticalLg,
        ContainerConfigSection(container: container),
        if (container.ports.isNotEmpty) ...[
          AppSpacing.verticalLg,
          ContainerPortsSection(container: container),
        ],
        AppSpacing.verticalLg,
        ContainerActionsSection(container: container),
        AppSpacing.verticalLg,
        ContainerLogsSection(containerId: container.id),
      ],
    );
  }
}
