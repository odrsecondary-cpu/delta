import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/km_split.dart';

class SplitsTable extends StatelessWidget {
  const SplitsTable({super.key, required this.splits});

  final List<KmSplit> splits;

  @override
  Widget build(BuildContext context) {
    if (splits.isEmpty) return const SizedBox.shrink();

    final maxSpeed = splits.fold(0.0, (m, s) => s.speedKmh > m ? s.speedKmh : m);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SPLITS',
            style: TextStyle(
              color: AppColors.whiteDim,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(8),
          for (final split in splits)
            _SplitRow(
              key: ValueKey(split.km),
              split: split,
              maxSpeedKmh: maxSpeed,
            ),
        ],
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    super.key,
    required this.split,
    required this.maxSpeedKmh,
  });

  final KmSplit split;
  final double maxSpeedKmh;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Row(
        children: [
          // Km index
          SizedBox(
            width: 36,
            child: Text(
              '${split.km} km',
              style: const TextStyle(color: AppColors.whiteMuted, fontSize: 16),
            ),
          ),
          const Gap(8),
          // Speed bar (proportional)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = maxSpeedKmh > 0
                    ? constraints.maxWidth * (split.speedKmh / maxSpeedKmh)
                    : 0.0;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 4,
                    width: barWidth,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ),
          const Gap(8),
          // Pace
          Text(
            split.paceLabel,
            style: const TextStyle(color: AppColors.whiteMuted, fontSize: 16),
          ),
          const Gap(10),
          // Speed
          SizedBox(
            width: 36,
            child: Text(
              split.speedLabel,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
