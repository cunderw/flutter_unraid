import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/notifications/notification_cubit.dart';
import 'package:flutter_unraid/blocs/notifications/notification_state.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/models/notification.dart' as models;
import 'package:flutter_unraid/ui/widgets/cards/action_card.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';
import 'package:flutter_unraid/ui/widgets/feedback/confirmation_dialog.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_snackbar.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';
import 'package:flutter_unraid/ui/widgets/layout/section_header.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listenWhen: (_, current) => current is NotificationActionError,
      listener: (context, state) {
        if (state is NotificationActionError) {
          showErrorSnackbar(context, message: state.message);
        }
      },
      child: BlocBuilder<NotificationCubit, NotificationState>(
        buildWhen: (_, current) => current is! NotificationActionError,
        builder: (context, state) {
          final notifications = switch (state) {
            NotificationLoaded(:final notifications) => notifications,
            NotificationActionError(:final notifications) => notifications,
            _ => null,
          };

          if (state is NotificationInitial || state is NotificationLoading) {
            return const LoadingIndicator(message: 'Loading notifications...');
          }

          if (state is NotificationError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () => context.read<NotificationCubit>().refresh(),
            );
          }

          if (notifications == null || notifications.isEmpty) {
            return const EmptyState(
              message: 'No notifications.',
              icon: Icons.notifications_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<NotificationCubit>().refresh(),
            color: AppColors.unraidOrange,
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              children: [
                SectionHeader(
                  title: 'Notifications',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${notifications.length} unread',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.horizontalSm,
                      if (notifications.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => context
                              .read<NotificationCubit>()
                              .archiveAllNotifications(),
                          icon: const Icon(Icons.done_all, size: 16),
                          label: const Text('Archive all'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.unraidOrange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ),
                ...notifications.map((n) => _NotificationTile(notification: n)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final models.Notification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return ActionCard(
      title: notification.subject,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _getImportanceColor().withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getImportanceIcon(),
          color: _getImportanceColor(),
          size: 18,
        ),
      ),
      actions: _buildActions(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.description.isNotEmpty) ...[
            Text(
              notification.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.verticalSm,
          ],
          Row(
            children: [
              StatusBadge(
                label: _getImportanceLabel(),
                color: _getImportanceColor(),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(notification.timestamp),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final cubit = context.read<NotificationCubit>();
    return [
      _actionButton(
        context,
        icon: Icons.archive_outlined,
        label: 'Archive',
        color: AppColors.running,
        onPressed: () => cubit.archiveNotification(notification.id),
      ),
      _actionButton(
        context,
        icon: Icons.delete_outline,
        label: 'Delete',
        color: AppColors.stopped,
        onPressed: () async {
          final confirmed = await showConfirmationDialog(
            context,
            title: 'Delete Notification',
            message: 'Are you sure you want to delete this notification?',
            confirmLabel: 'Delete',
            isDestructive: true,
          );
          if (confirmed && context.mounted) {
            cubit.deleteNotification(notification.id);
          }
        },
      ),
    ];
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Color _getImportanceColor() {
    return switch (notification.importance) {
      models.NotificationImportance.alert => AppColors.stopped,
      models.NotificationImportance.warning => AppColors.warning,
      models.NotificationImportance.info => AppColors.running,
      models.NotificationImportance.unknown => AppColors.offline,
    };
  }

  IconData _getImportanceIcon() {
    return switch (notification.importance) {
      models.NotificationImportance.alert => Icons.error_outline,
      models.NotificationImportance.warning => Icons.warning_amber_outlined,
      models.NotificationImportance.info => Icons.info_outline,
      models.NotificationImportance.unknown => Icons.help_outline,
    };
  }

  String _getImportanceLabel() {
    return switch (notification.importance) {
      models.NotificationImportance.alert => 'Alert',
      models.NotificationImportance.warning => 'Warning',
      models.NotificationImportance.info => 'Info',
      models.NotificationImportance.unknown => 'Unknown',
    };
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
