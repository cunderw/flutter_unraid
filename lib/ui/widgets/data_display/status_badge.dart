import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/theme.dart';

/// Colored badge indicating entity state (running, stopped, etc.).
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double size;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.size = 8,
  });

  /// Creates a badge from a container state string.
  factory StatusBadge.forContainerState(String state) {
    final color = switch (state.toUpperCase()) {
      'RUNNING' => AppColors.running,
      'PAUSED' => AppColors.paused,
      'EXITED' || 'STOPPED' => AppColors.stopped,
      _ => AppColors.offline,
    };
    return StatusBadge(label: _formatState(state), color: color);
  }

  /// Creates a badge from a VM state string.
  factory StatusBadge.forVmState(String state) {
    final color = switch (state.toUpperCase()) {
      'RUNNING' => AppColors.running,
      'PAUSED' || 'PMSUSPENDED' => AppColors.paused,
      'SHUTOFF' || 'SHUTDOWN' => AppColors.stopped,
      'CRASHED' => AppColors.warning,
      _ => AppColors.offline,
    };
    return StatusBadge(label: _formatState(state), color: color);
  }

  /// Creates a badge from an array state string.
  factory StatusBadge.forArrayState(String state) {
    final color = switch (state.toUpperCase()) {
      'STARTED' => AppColors.running,
      'STOPPED' => AppColors.stopped,
      _ => AppColors.offline,
    };
    return StatusBadge(label: _formatState(state), color: color);
  }

  static String _formatState(String state) {
    return state[0].toUpperCase() + state.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
