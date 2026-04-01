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
    this.accentColor,
  });

  final String label;
  final String value;
  final String unit;

  /// When true, the card uses a tinted highlight — used for Speed when moving.
  final bool highlighted;

  /// Overrides the highlight color (defaults to [AppColors.green]).
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.green;
    final bg = highlighted
        ? accent.withValues(alpha: 0.12)
        : AppColors.surface;
    final borderColor = highlighted
        ? accent.withValues(alpha: 0.35)
        : AppColors.surfaceBorder;
    final valueColor = highlighted ? accent : AppColors.white;

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.whiteMuted,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
            ),
          ),
        ],
      ),
    );
  }
}
