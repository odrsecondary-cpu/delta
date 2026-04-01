import 'package:latlong2/latlong.dart';

import '../../models/km_split.dart';
import '../../models/track_point.dart';

const _calc = Distance();

/// Computes per-kilometre splits from GPS track points.
/// Uses linear interpolation to find precise km-boundary timestamps.
List<KmSplit> computeSplits(List<TrackPoint> points) {
  if (points.length < 2) return [];

  var cumDist = 0.0; // meters
  var lastKmDist = 0.0; // meters at last km boundary
  var lastKmTime = points.first.timestamp;
  var nextKm = 1;
  final splits = <KmSplit>[];

  for (var i = 1; i < points.length; i++) {
    final segDist = _calc.as(
      LengthUnit.Meter,
      points[i - 1].position,
      points[i].position,
    );
    final prevCumDist = cumDist;
    cumDist += segDist;

    // A single segment might span multiple km boundaries.
    while (cumDist >= nextKm * 1000.0) {
      final kmBoundaryDist = nextKm * 1000.0;
      final fraction =
          segDist > 0 ? (kmBoundaryDist - prevCumDist) / segDist : 1.0;
      final segDuration =
          points[i].timestamp.difference(points[i - 1].timestamp);
      final boundaryTime = points[i - 1].timestamp.add(
        Duration(
          microseconds: (segDuration.inMicroseconds * fraction).round(),
        ),
      );

      final splitDuration = boundaryTime.difference(lastKmTime);
      final splitDistKm = (kmBoundaryDist - lastKmDist) / 1000.0;
      final durationSec = splitDuration.inSeconds.clamp(1, 99999).toDouble();

      splits.add(KmSplit(
        km: nextKm,
        speedKmh: splitDistKm / (durationSec / 3600.0),
        paceSeconds: (durationSec / splitDistKm).round(),
      ));

      lastKmDist = kmBoundaryDist;
      lastKmTime = boundaryTime;
      nextKm++;
    }
  }

  return splits;
}

/// Computes (distKm, altM) pairs for the elevation profile chart.
/// Downsamples to [maxPoints] for rendering performance.
List<({double distKm, double altM})> computeElevationPoints(
  List<TrackPoint> points, {
  int maxPoints = 200,
}) {
  if (points.isEmpty) return [];
  if (points.length == 1) {
    return [(distKm: 0.0, altM: points.first.altitude)];
  }

  var cumDist = 0.0;
  final full = <({double distKm, double altM})>[
    (distKm: 0.0, altM: points.first.altitude),
  ];

  for (var i = 1; i < points.length; i++) {
    cumDist += _calc.as(
      LengthUnit.Meter,
      points[i - 1].position,
      points[i].position,
    );
    full.add((distKm: cumDist / 1000.0, altM: points[i].altitude));
  }

  if (full.length <= maxPoints) return full;

  final step = full.length / maxPoints;
  return List.generate(
    maxPoints,
    (i) => full[(i * step).round().clamp(0, full.length - 1)],
  );
}
