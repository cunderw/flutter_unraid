import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_snackbar.dart';

class ContainerLogsSection extends StatefulWidget {
  final String containerId;

  const ContainerLogsSection({super.key, required this.containerId});

  @override
  State<ContainerLogsSection> createState() => _ContainerLogsSectionState();
}

class _ContainerLogsSectionState extends State<ContainerLogsSection> {
  List<Map<String, dynamic>>? _lines;
  bool _loading = false;
  String? _error;
  bool _expanded = false;

  Future<void> _loadLogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = GetIt.I<DockerRepository>();
      final lines = await repo.getContainerLogs(widget.containerId);
      if (mounted) {
        setState(() {
          _lines = lines;
          _loading = false;
          _expanded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load logs';
          _loading = false;
        });
        showErrorSnackbar(context, message: 'Failed to load container logs');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (_lines == null && !_loading) {
                _loadLogs();
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.unraidOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.unraidOrange,
                      ),
                    )
                  else if (_lines != null)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      color: AppColors.textSecondary,
                      onPressed: _loadLogs,
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
          if (_expanded && _error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.stopped, fontSize: 13),
              ),
            ),
          if (_expanded && _lines != null)
            Container(
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
              child: _lines!.isEmpty
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
                  : Scrollbar(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        shrinkWrap: true,
                        itemCount: _lines!.length,
                        itemBuilder: (context, index) {
                          final line = _lines![index];
                          final timestamp = line['timestamp'] as String?;
                          final message = line['message'] as String? ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xxxs,
                            ),
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
            ),
        ],
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
