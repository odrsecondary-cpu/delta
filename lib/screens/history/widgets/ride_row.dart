import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/ride.dart';

class RideRow extends StatelessWidget {
  const RideRow({
    super.key,
    required this.ride,
    required this.onTap,
  });

  final Ride ride;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: _RowContent(ride: ride),
      ),
    );
  }
}

class _RowContent extends StatelessWidget {
  const _RowContent({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Date + time — 1fr
        Expanded(
          child: Row(
            children: [
              Text(
                RideFormatters.shortDate(ride.startTime),
                style: const TextStyle(
                  color: AppColors.whiteMuted,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                RideFormatters.time12h(ride.startTime),
                style: const TextStyle(
                  color: AppColors.whiteDim,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        // Duration — 72 px
        SizedBox(
          width: 72,
          child: Text(
            RideFormatters.duration(ride.duration),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.whiteDim,
              fontSize: 18,
            ),
          ),
        ),
        // Gap — 20 px
        const Gap(20),
        // Distance — 84 px
        SizedBox(
          width: 84,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                RideFormatters.distanceValue(ride.totalDistance),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 1),
              const Text(
                'km',
                style: TextStyle(
                  color: AppColors.whiteMuted,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
