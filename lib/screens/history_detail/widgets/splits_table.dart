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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'SPLITS',
              style: TextStyle(
                color: AppColors.whiteDim,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Gap(8),
          const _SplitsHeader(),
          const Gap(4),
          for (final split in splits)
            _SplitRow(
              key: ValueKey(split.km),
              split: split,
            ),
        ],
      ),
    );
  }
}

class _SplitsHeader extends StatelessWidget {
  const _SplitsHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: AppColors.whiteDim,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
    );
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 10),
      child: Row(
        children: [
          const SizedBox(width: 52, child: Text('KM', style: style)),
          const Expanded(child: Center(child: Text('TIME', style: style))),
          SizedBox(
            width: 80,
            child: const Text('SPEED', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({super.key, required this.split});

  final KmSplit split;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Row(
        children: [
          // Kilometer
          SizedBox(
            width: 52,
            child: Text(
              '${split.km} km',
              style: const TextStyle(
                color: AppColors.whiteMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Time (pace mm:ss min)
          Expanded(
            child: Center(
              child: Text(
                '${split.timeLabel} min',
                style: const TextStyle(
                  color: AppColors.whiteMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Speed
          SizedBox(
            width: 80,
            child: Text(
              '${split.speedLabel} km/h',
              textAlign: TextAlign.right,
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
