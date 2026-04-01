import 'package:latlong2/latlong.dart';

import '../../models/track_point.dart';

enum RideStatus { idle, active, paused }

class ActivityState {
  const ActivityState({
    this.status = RideStatus.idle,
    this.startTime,
    this.elapsed = Duration.zero,
    this.speedKmh = 0.0,
    this.maxSpeedKmh = 0.0,
    this.distanceKm = 0.0,
    this.altitudeM = 0.0,
    this.elevationGain = 0.0,
    this.trackPoints = const [],
    this.currentPosition,
    this.permissionDenied = false,
  });

  final RideStatus status;
  final DateTime? startTime;
  final Duration elapsed;
  final double speedKmh;
  final double maxSpeedKmh;
  final double distanceKm;
  final double altitudeM;
  final double elevationGain;
  final List<TrackPoint> trackPoints;
  final LatLng? currentPosition;
  final bool permissionDenied;

  List<LatLng> get positions => trackPoints.map((tp) => tp.position).toList();

  bool get isMoving => speedKmh > 0.5;
  bool get isActive => status == RideStatus.active;
  bool get isPaused => status == RideStatus.paused;
  bool get isIdle => status == RideStatus.idle;

  ActivityState copyWith({
    RideStatus? status,
    DateTime? startTime,
    Duration? elapsed,
    double? speedKmh,
    double? maxSpeedKmh,
    double? distanceKm,
    double? altitudeM,
    double? elevationGain,
    List<TrackPoint>? trackPoints,
    LatLng? currentPosition,
    bool? permissionDenied,
  }) {
    return ActivityState(
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
      speedKmh: speedKmh ?? this.speedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      distanceKm: distanceKm ?? this.distanceKm,
      altitudeM: altitudeM ?? this.altitudeM,
      elevationGain: elevationGain ?? this.elevationGain,
      trackPoints: trackPoints ?? this.trackPoints,
      currentPosition: currentPosition ?? this.currentPosition,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}
