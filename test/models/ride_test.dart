import 'package:flutter_test/flutter_test.dart';
import 'package:gamma/models/ride.dart';

void main() {
  group('Ride.fromMap / toMap round-trip', () {
    final startTime = DateTime(2026, 3, 29, 9, 30);

    final ride = Ride(
      id: 42,
      name: 'Morning ride',
      startTime: startTime,
      totalDistance: 12.5,
      avgSpeed: 22.3,
      maxSpeed: 47.1,
      duration: const Duration(minutes: 34),
      movingTime: const Duration(minutes: 32),
      elevationGain: 85.0,
      cadence: 88.5,
    );

    test('should round-trip all fields through toMap / fromMap', () {
      final map = ride.toMap();
      final restored = Ride.fromMap(map);

      expect(restored.id, ride.id);
      expect(restored.name, ride.name);
      expect(restored.startTime, ride.startTime);
      expect(restored.totalDistance, ride.totalDistance);
      expect(restored.avgSpeed, ride.avgSpeed);
      expect(restored.maxSpeed, ride.maxSpeed);
      expect(restored.duration, ride.duration);
      expect(restored.movingTime, ride.movingTime);
      expect(restored.elevationGain, ride.elevationGain);
      expect(restored.cadence, ride.cadence);
    });

    test('should omit id from toMap when id == 0', () {
      final newRide = Ride(
        name: 'New',
        startTime: startTime,
        totalDistance: 1.0,
        avgSpeed: 10.0,
        maxSpeed: 15.0,
        duration: const Duration(minutes: 6),
        movingTime: const Duration(minutes: 6),
        elevationGain: 0.0,
      );
      expect(newRide.toMap().containsKey('id'), isFalse);
    });

    test('should include id in toMap when id > 0', () {
      expect(ride.toMap()['id'], 42);
    });

    test('should handle null cadence', () {
      final noCadence = Ride(
        id: 1,
        name: 'No cadence',
        startTime: startTime,
        totalDistance: 5.0,
        avgSpeed: 20.0,
        maxSpeed: 30.0,
        duration: const Duration(minutes: 15),
        movingTime: const Duration(minutes: 15),
        elevationGain: 20.0,
      );
      final restored = Ride.fromMap(noCadence.toMap());
      expect(restored.cadence, isNull);
    });

    test('copyWith should update name while preserving other fields', () {
      final renamed = ride.copyWith(name: 'Evening ride');
      expect(renamed.name, 'Evening ride');
      expect(renamed.id, ride.id);
      expect(renamed.totalDistance, ride.totalDistance);
      expect(renamed.trackPoints, ride.trackPoints);
    });
  });
}
