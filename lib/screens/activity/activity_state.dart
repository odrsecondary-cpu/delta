import 'package:latlong2/latlong.dart';

enum RideStatus { idle, active, paused }

class ActivityState {
  const ActivityState({
    this.status = RideStatus.idle,
    this.elapsed = Duration.zero,
    this.speedKmh = 0.0,
    this.distanceKm = 0.0,
    this.altitudeM = 0.0,
    this.trackPoints = const [],
    this.currentPosition,
    this.permissionDenied = false,
  });

  final RideStatus status;
  final Duration elapsed;
  final double speedKmh;
  final double distanceKm;
  final double altitudeM;
  final List<LatLng> trackPoints;
  final LatLng? currentPosition;
  final bool permissionDenied;

  bool get isMoving => speedKmh > 0.5;
  bool get isActive => status == RideStatus.active;
  bool get isPaused => status == RideStatus.paused;
  bool get isIdle => status == RideStatus.idle;

  ActivityState copyWith({
    RideStatus? status,
    Duration? elapsed,
    double? speedKmh,
    double? distanceKm,
    double? altitudeM,
    List<LatLng>? trackPoints,
    LatLng? currentPosition,
    bool? permissionDenied,
  }) {
    return ActivityState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      speedKmh: speedKmh ?? this.speedKmh,
      distanceKm: distanceKm ?? this.distanceKm,
      altitudeM: altitudeM ?? this.altitudeM,
      trackPoints: trackPoints ?? this.trackPoints,
      currentPosition: currentPosition ?? this.currentPosition,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}
