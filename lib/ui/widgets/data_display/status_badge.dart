import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';

/// Colored badge indicating entity state (running, stopped, etc.).
class StatusBadge extends StatefulWidget {
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
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  bool get _shouldPulse => widget.color == AppColors.running;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_shouldPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldPulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!_shouldPulse && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _shouldPulse
              ? AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => Opacity(
                    opacity: _pulse.value,
                    child: _dot,
                  ),
                )
              : _dot,
          AppSpacing.horizontalXs,
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: widget.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _dot => Container(
    width: widget.size,
    height: widget.size,
    decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
  );
}
