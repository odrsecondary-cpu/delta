import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/ride.dart';

class TotalBar extends StatelessWidget {
  const TotalBar({super.key, required this.rides});

  final List<Ride> rides;

  Duration get _totalDuration =>
      rides.fold(Duration.zero, (s, r) => s + r.duration);

  double get _totalDistance =>
      rides.fold(0.0, (s, r) => s + r.totalDistance);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.totalBarBg,
        border: Border(
          top: BorderSide(color: AppColors.greenBrightMuted, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Total',
              style: TextStyle(
                color: AppColors.greenBright,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              RideFormatters.duration(_totalDuration),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.greenBright,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Gap(20),
          SizedBox(
            width: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  RideFormatters.distanceValue(_totalDistance),
                  style: const TextStyle(
                    color: AppColors.greenBright,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 1),
                Text(
                  'km',
                  style: TextStyle(
                    color: AppColors.greenBright.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
