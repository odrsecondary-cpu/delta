import 'package:latlong2/latlong.dart';

class TrackPoint {
  const TrackPoint({
    required this.position,
    required this.speed,
    required this.timestamp,
    required this.altitude,
    this.segmentBreak = false,
  });

  final LatLng position;
  final double speed; // km/h
  final DateTime timestamp;
  final double altitude; // meters
  /// True for the first point of a new segment (first point after resume).
  final bool segmentBreak;
}
