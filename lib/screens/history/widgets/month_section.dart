import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/ride.dart';
import 'ride_row.dart';

class MonthSection extends StatelessWidget {
  const MonthSection({
    super.key,
    required this.month,
    required this.rides,
    required this.isCollapsed,
    required this.onToggle,
    required this.onRideTap,
  });

  final DateTime month;
  final List<Ride> rides;
  final bool isCollapsed;
  final VoidCallback onToggle;
  final ValueChanged<Ride> onRideTap;

  Duration get _totalDuration =>
      rides.fold(Duration.zero, (s, r) => s + r.duration);

  double get _totalDistance =>
      rides.fold(0.0, (s, r) => s + r.totalDistance);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          month: month,
          totalDuration: _totalDuration,
          totalDistance: _totalDistance,
          isCollapsed: isCollapsed,
          onToggle: onToggle,
        ),
        AnimatedCrossFade(
          firstChild: _RideList(rides: rides, onRideTap: onRideTap),
          secondChild: const SizedBox.shrink(),
          crossFadeState: isCollapsed
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const Gap(8),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.month,
    required this.totalDuration,
    required this.totalDistance,
    required this.isCollapsed,
    required this.onToggle,
  });

  final DateTime month;
  final Duration totalDuration;
  final double totalDistance;
  final bool isCollapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            // Month name + year — 1fr
            Expanded(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        RideFormatters.monthName(month),
                        style: const TextStyle(
                          color: AppColors.greenBright,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        RideFormatters.year(month),
                        style: TextStyle(
                          color: AppColors.greenBright.withValues(alpha: 0.5),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: isCollapsed ? -0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.greenBright,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Total duration — 52 px
            SizedBox(
              width: 52,
              child: Text(
                RideFormatters.duration(totalDuration),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.whiteMuted,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Gap — 20 px
            const Gap(20),
            // Total distance — 52 px
            SizedBox(
              width: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    RideFormatters.distanceValue(totalDistance),
                    style: const TextStyle(
                      color: AppColors.whiteMuted,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 1),
                  Text(
                    'km',
                    style: TextStyle(
                      color: AppColors.whiteMuted.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideList extends StatelessWidget {
  const _RideList({required this.rides, required this.onRideTap});

  final List<Ride> rides;
  final ValueChanged<Ride> onRideTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final ride in rides)
          RideRow(
            key: ValueKey(ride.id),
            ride: ride,
            onTap: () => onRideTap(ride),
          ),
      ],
    );
  }
}
