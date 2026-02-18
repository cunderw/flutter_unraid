import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/ui/screens/vm_detail/cubit/vm_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/vm_detail/cubit/vm_logs_state.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/ui/widgets/feedback/inline_error.dart';

class VmLogsSection extends StatefulWidget {
  final String vmId;

  const VmLogsSection({super.key, required this.vmId});

  @override
  State<VmLogsSection> createState() => _VmLogsSectionState();
}

class _VmLogsSectionState extends State<VmLogsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VmLogsCubit, VmLogsState>(
      builder: (context, state) {
        final isLoading = state is VmLogsLoading;
        final hasData = state is VmLogsLoaded;
        final hasError = state is VmLogsError;

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (state is VmLogsInitial && !isLoading) {
                    context.read<VmLogsCubit>().load();
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
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
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
                              context.read<VmLogsCubit>().refresh(),
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
                    onRetry: () => context.read<VmLogsCubit>().refresh(),
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
  final List<String> lines;

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
    );
  }
}
