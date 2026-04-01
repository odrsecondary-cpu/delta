import 'track_point.dart';

class Ride {
  const Ride({
    this.id = 0,
    required this.name,
    required this.startTime,
    required this.totalDistance,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.duration,
    required this.movingTime,
    required this.elevationGain,
    this.cadence,
    this.trackPoints = const [],
  });

  /// 0 means the ride has not been persisted yet.
  final int id;
  final String name;
  final DateTime startTime;
  final double totalDistance; // km
  final double avgSpeed; // km/h
  final double maxSpeed; // km/h
  final Duration duration;
  final Duration movingTime;
  final double elevationGain; // m
  final double? cadence; // rpm, null when no BLE sensor
  final List<TrackPoint> trackPoints;

  /// Columns written to the `rides` table.
  /// Excludes `id` when [id] == 0 so AUTOINCREMENT kicks in.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'start_time': startTime.millisecondsSinceEpoch,
      'total_distance': totalDistance,
      'avg_speed': avgSpeed,
      'max_speed': maxSpeed,
      'duration_ms': duration.inMilliseconds,
      'moving_time_ms': movingTime.inMilliseconds,
      'elevation_gain': elevationGain,
      'cadence': cadence,
    };
    if (id > 0) map['id'] = id;
    return map;
  }

  factory Ride.fromMap(Map<String, dynamic> map) => Ride(
    id: map['id'] as int,
    name: map['name'] as String,
    startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
    totalDistance: (map['total_distance'] as num).toDouble(),
    avgSpeed: (map['avg_speed'] as num).toDouble(),
    maxSpeed: (map['max_speed'] as num).toDouble(),
    duration: Duration(milliseconds: map['duration_ms'] as int),
    movingTime: Duration(milliseconds: map['moving_time_ms'] as int),
    elevationGain: (map['elevation_gain'] as num).toDouble(),
    cadence: (map['cadence'] as num?)?.toDouble(),
  );

  Ride copyWith({
    String? name,
    List<TrackPoint>? trackPoints,
  }) =>
      Ride(
        id: id,
        name: name ?? this.name,
        startTime: startTime,
        totalDistance: totalDistance,
        avgSpeed: avgSpeed,
        maxSpeed: maxSpeed,
        duration: duration,
        movingTime: movingTime,
        elevationGain: elevationGain,
        cadence: cadence,
        trackPoints: trackPoints ?? this.trackPoints,
      );
}
