import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';

class ElevationChartPanel extends StatelessWidget {
  const ElevationChartPanel({
    super.key,
    required this.elevationPoints,
  });

  final List<({double distKm, double altM})> elevationPoints;

  @override
  Widget build(BuildContext context) {
    final maxDist = elevationPoints.isEmpty ? 1.0 : elevationPoints.last.distKm;
    final midDist = maxDist / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ELEVATION PROFILE',
            style: TextStyle(
              color: AppColors.whiteDim,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(8),
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Stack(
              children: [
                _Chart(elevationPoints: elevationPoints),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0.0 km',
                        style: const TextStyle(color: AppColors.whiteDim, fontSize: 9),
                      ),
                      Text(
                        '${midDist.toStringAsFixed(1)} km',
                        style: const TextStyle(color: AppColors.whiteDim, fontSize: 9),
                      ),
                      Text(
                        '${maxDist.toStringAsFixed(1)} km',
                        style: const TextStyle(color: AppColors.whiteDim, fontSize: 9),
                      ),
                    ],
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

class _Chart extends StatelessWidget {
  const _Chart({required this.elevationPoints});

  final List<({double distKm, double altM})> elevationPoints;

  @override
  Widget build(BuildContext context) {
    final spots = elevationPoints
        .map((p) => FlSpot(p.distKm, p.altM))
        .toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.green,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.green.withValues(alpha: 0.45),
                  AppColors.green.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
