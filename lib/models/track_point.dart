import 'package:latlong2/latlong.dart';

class TrackPoint {
  const TrackPoint({
    required this.position,
    required this.speed,
    required this.timestamp,
    required this.altitude,
  });

  final LatLng position;
  final double speed; // km/h
  final DateTime timestamp;
  final double altitude; // meters
}
