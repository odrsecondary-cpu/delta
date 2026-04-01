import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import 'ride_detail_provider.dart';
import 'widgets/detail_header.dart';
import 'widgets/detail_map_panel.dart';
import 'widgets/detail_metric_grid.dart';
import 'widgets/elevation_chart_panel.dart';
import 'widgets/splits_table.dart';

class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.rideId});

  final int rideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(rideDetailProvider(rideId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          ),
          error: (_, _) => const Center(
            child: Text(
              'Failed to load ride',
              style: TextStyle(color: AppColors.whiteMuted),
            ),
          ),
          data: (detail) => _DetailContent(detail: detail),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail});

  final RideDetail detail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailHeader(ride: detail.ride),
          DetailMapPanel(trackPoints: detail.ride.trackPoints),
          const Gap(12),
          DetailMetricGrid(ride: detail.ride),
          if (detail.hasTrackData) ...[
            const Gap(16),
            ElevationChartPanel(elevationPoints: detail.elevationPoints),
          ],
          if (detail.splits.isNotEmpty) ...[
            const Gap(16),
            SplitsTable(splits: detail.splits),
          ],
        ],
      ),
    );
  }
}
