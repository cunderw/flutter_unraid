import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/cubit/system_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/cubit/system_logs_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/inline_error.dart';

class SystemLogsSection extends StatefulWidget {
  const SystemLogsSection({super.key});

  @override
  State<SystemLogsSection> createState() => _SystemLogsSectionState();
}

class _SystemLogsSectionState extends State<SystemLogsSection> {
  bool _expanded = false;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemLogsCubit, SystemLogsState>(
      builder: (context, state) {
        final isLoading = state is SystemLogsLoading;
        final hasData = state is SystemLogsLoaded;
        final hasError = state is SystemLogsError;

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (state is SystemLogsInitial && !isLoading) {
                    context.read<SystemLogsCubit>().load(lines: 10);
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
                          'System Logs',
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
                          onPressed: () {
                            final lines = _showAll ? null : 10;
                            context.read<SystemLogsCubit>().refresh(
                              lines: lines,
                            );
                          },
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
                    onRetry: () {
                      final lines = _showAll ? null : 10;
                      context.read<SystemLogsCubit>().refresh(lines: lines);
                    },
                  ),
                ),
              if (_expanded && hasData)
                _LogsContent(
                  lines: state.lines,
                  showAll: _showAll,
                  onViewAllToggle: () {
                    setState(() => _showAll = !_showAll);
                    final lines = !_showAll ? 10 : null;
                    context.read<SystemLogsCubit>().load(lines: lines);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LogsContent extends StatelessWidget {
  final List<String> lines;
  final bool showAll;
  final VoidCallback onViewAllToggle;

  const _LogsContent({
    required this.lines,
    required this.showAll,
    required this.onViewAllToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 400),
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
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
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      final line = lines[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxxs),
                        child: Text(
                          line,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        if (lines.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Center(
              child: TextButton.icon(
                onPressed: onViewAllToggle,
                icon: Icon(
                  showAll ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                label: Text(showAll ? 'Show Last 10' : 'View All'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.unraidOrange,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
