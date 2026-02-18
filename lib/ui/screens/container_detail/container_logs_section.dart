import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/ui/screens/container_detail/cubit/container_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/container_detail/cubit/container_logs_state.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/ui/widgets/feedback/inline_error.dart';

class ContainerLogsSection extends StatefulWidget {
  final String containerId;

  const ContainerLogsSection({super.key, required this.containerId});

  @override
  State<ContainerLogsSection> createState() => _ContainerLogsSectionState();
}

class _ContainerLogsSectionState extends State<ContainerLogsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContainerLogsCubit, ContainerLogsState>(
      builder: (context, state) {
        final isLoading = state is ContainerLogsLoading;
        final hasData = state is ContainerLogsLoaded;
        final hasError = state is ContainerLogsError;

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (state is ContainerLogsInitial && !isLoading) {
                    context.read<ContainerLogsCubit>().load();
                    setState(() => _expanded = true);
                  } else {
                    setState(() => _expanded = !_expanded);
                  }
                },
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                  bottom: Radius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Logs',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.unraidOrange,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.unraidOrange,
                          ),
                        )
                      else if (hasData || hasError)
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          color: AppColors.textSecondary,
                          onPressed: () =>
                              context.read<ContainerLogsCubit>().refresh(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      AppSpacing.horizontalSm,
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_expanded && hasError)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: InlineError(
                    message: state.message,
                    onRetry: () => context.read<ContainerLogsCubit>().refresh(),
                  ),
                ),
              if (_expanded && hasData) _LogsContent(lines: state.lines),
            ],
          ),
        );
      },
    );
  }
}

class _LogsContent extends StatelessWidget {
  final List<Map<String, dynamic>> lines;

  const _LogsContent({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 400),
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: lines.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'No logs available.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            )
          : Scrollbar(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                shrinkWrap: true,
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  final line = lines[index];
                  final timestamp = line['timestamp'] as String?;
                  final message = line['message'] as String? ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxxs),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (timestamp != null)
                            TextSpan(
                              text: '${_formatTimestamp(timestamp)} ',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          TextSpan(
                            text: message,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return timestamp;
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }
}
