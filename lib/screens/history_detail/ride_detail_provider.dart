import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/ride_math.dart';
import '../../models/km_split.dart';
import '../../models/ride.dart';
import '../../services/database_service.dart';

class RideDetail {
  const RideDetail({
    required this.ride,
    required this.elevationPoints,
    required this.splits,
  });

  final Ride ride;
  final List<({double distKm, double altM})> elevationPoints;
  final List<KmSplit> splits;

  bool get hasTrackData => ride.trackPoints.isNotEmpty;
}

final rideDetailProvider =
    FutureProvider.family<RideDetail, int>((ref, id) async {
  final ride =
      await ref.read(databaseServiceProvider).getRideWithTrackPoints(id);
  return RideDetail(
    ride: ride,
    elevationPoints: computeElevationPoints(ride.trackPoints),
    splits: computeSplits(ride.trackPoints),
  );
});
