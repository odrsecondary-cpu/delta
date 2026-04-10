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
    this.routeSegments = const [],
    this.currentPosition,
    this.permissionDenied = false,
    this.gpsError,
    this.saveError,
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
  /// Separate polyline segments — a new segment starts after each resume.
  final List<List<LatLng>> routeSegments;
  final LatLng? currentPosition;
  final bool permissionDenied;
  /// Non-null when the GPS stream emitted an error during an active ride.
  final String? gpsError;
  /// Non-null when the database failed to save the ride on the last attempt.
  final String? saveError;

  bool get isMoving => speedKmh > 0.5;
  bool get isActive => status == RideStatus.active;
  bool get isPaused => status == RideStatus.paused;
  bool get isIdle => status == RideStatus.idle;

  // Sentinel used in copyWith to distinguish "not provided" from explicit null.
  static const Object _absent = Object();

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
    List<List<LatLng>>? routeSegments,
    LatLng? currentPosition,
    bool? permissionDenied,
    Object? gpsError = _absent,
    Object? saveError = _absent,
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
      routeSegments: routeSegments ?? this.routeSegments,
      currentPosition: currentPosition ?? this.currentPosition,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      gpsError: identical(gpsError, _absent) ? this.gpsError : gpsError as String?,
      saveError: identical(saveError, _absent) ? this.saveError : saveError as String?,
    );
  }
}
