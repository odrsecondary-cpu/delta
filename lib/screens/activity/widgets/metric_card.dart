import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Single metric card used in the 2×2 grid on the Activity screen.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final String unit;

  /// When true, the card uses a green tint — used for Speed when moving.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bg = highlighted
        ? AppColors.green.withValues(alpha: 0.12)
        : AppColors.surface;
    final borderColor = highlighted
        ? AppColors.green.withValues(alpha: 0.35)
        : AppColors.surfaceBorder;
    final valueColor = highlighted ? AppColors.green : AppColors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.whiteMuted,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.whiteMuted,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
