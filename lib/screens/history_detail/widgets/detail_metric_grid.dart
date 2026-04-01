import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/ride.dart';

class DetailMetricGrid extends StatelessWidget {
  const DetailMetricGrid({super.key, required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Row 1: Distance (accented, full-width) + Moving time
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'DISTANCE',
                  value: RideFormatters.distanceValue(ride.totalDistance),
                  unit: 'km',
                  accented: true,
                ),
              ),
              const Gap(6),
              Expanded(
                child: _MetricCard(
                  label: 'MOVING TIME',
                  value: RideFormatters.duration(ride.movingTime),
                  unit: '',
                ),
              ),
            ],
          ),
          const Gap(6),
          // Row 2: Avg speed + Top speed
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'AVG SPEED',
                  value: ride.avgSpeed.toStringAsFixed(1),
                  unit: 'km/h',
                ),
              ),
              const Gap(6),
              Expanded(
                child: _MetricCard(
                  label: 'TOP SPEED',
                  value: ride.maxSpeed.toStringAsFixed(1),
                  unit: 'km/h',
                ),
              ),
            ],
          ),
          const Gap(6),
          // Row 3: Elevation gain (full-width)
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'ELEVATION GAIN',
                  value: ride.elevationGain.toStringAsFixed(0),
                  unit: 'm',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    this.accented = false,
  });

  final String label;
  final String value;
  final String unit;
  final bool accented;

  @override
  Widget build(BuildContext context) {
    final bgColor = accented ? AppColors.totalBarBg : AppColors.surface;
    final labelColor =
        accented ? AppColors.greenBright.withValues(alpha: 0.6) : AppColors.whiteDim;
    final valueColor = accented ? AppColors.greenBright : AppColors.white;
    final unitColor = accented
        ? AppColors.greenBright.withValues(alpha: 0.5)
        : AppColors.whiteMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: TextStyle(color: unitColor, fontSize: 11),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
