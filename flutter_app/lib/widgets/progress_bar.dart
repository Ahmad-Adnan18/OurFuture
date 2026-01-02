import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;

  const ProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final progressColor = color ?? _getColorForProgress(clampedProgress, colorScheme);
    final bgColor = backgroundColor ?? colorScheme.surfaceVariant;
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedProgress,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: radius,
          ),
        ),
      ),
    );
  }

  Color _getColorForProgress(double progress, ColorScheme colorScheme) {
    if (progress >= 1.0) {
      return Colors.green;
    } else if (progress >= 0.75) {
      return colorScheme.primary;
    } else if (progress >= 0.5) {
      return Colors.orange;
    } else if (progress >= 0.25) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}
