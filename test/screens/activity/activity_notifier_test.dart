import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gamma/models/ride.dart';
import 'package:gamma/screens/activity/activity_notifier.dart';
import 'package:gamma/screens/activity/activity_state.dart';
import 'package:gamma/services/database_service.dart';
import 'package:gamma/services/gps_service.dart';

class MockGpsService extends Mock implements GpsService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class FakeRide extends Fake implements Ride {}

// Convenience wrapper so tests can read the current state without re-watching.
extension on ProviderContainer {
  ActivityState get activity => read(activityProvider);
  ActivityNotifier get activityNotifier => read(activityProvider.notifier);
}

void main() {
  setUpAll(() => registerFallbackValue(FakeRide()));

  late MockGpsService mockGps;
  late MockDatabaseService mockDb;
  late ProviderContainer container;

  setUp(() {
    mockGps = MockGpsService();
    mockDb = MockDatabaseService();
    container = ProviderContainer(
      overrides: [
        gpsServiceProvider.overrideWithValue(mockGps),
        databaseServiceProvider.overrideWithValue(mockDb),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('initial state', () {
    test('should be idle with zero metrics', () {
      final state = container.activity;
      expect(state.status, RideStatus.idle);
      expect(state.distanceKm, 0.0);
      expect(state.speedKmh, 0.0);
      expect(state.elapsed, Duration.zero);
      expect(state.trackPoints, isEmpty);
      expect(state.currentPosition, isNull);
      expect(state.permissionDenied, isFalse);
    });
  });

  group('startRide', () {
    test('should set permissionDenied when GPS permission is refused', () async {
      when(() => mockGps.requestPermission()).thenAnswer((_) async => false);

      await container.activityNotifier.startRide();

      expect(container.activity.permissionDenied, isTrue);
      expect(container.activity.status, RideStatus.idle);
    });

    test('should become active when GPS permission is granted', () async {
      when(() => mockGps.requestPermission()).thenAnswer((_) async => true);
      when(() => mockGps.positionStream())
          .thenAnswer((_) => const Stream.empty());

      await container.activityNotifier.startRide();

      expect(container.activity.status, RideStatus.active);
      expect(container.activity.permissionDenied, isFalse);
    });
  });

  group('pause / resume', () {
    setUp(() async {
      when(() => mockGps.requestPermission()).thenAnswer((_) async => true);
      when(() => mockGps.positionStream())
          .thenAnswer((_) => const Stream.empty());
      await container.activityNotifier.startRide();
    });

    test('should transition to paused', () {
      container.activityNotifier.pauseRide();
      expect(container.activity.status, RideStatus.paused);
    });

    test('should transition back to active after resume', () {
      container.activityNotifier.pauseRide();
      container.activityNotifier.resumeRide();
      expect(container.activity.status, RideStatus.active);
    });
  });

  group('saveAndStop', () {
    test('should save ride and reset to idle with zeroed metrics', () async {
      when(() => mockGps.requestPermission()).thenAnswer((_) async => true);
      when(() => mockGps.positionStream())
          .thenAnswer((_) => const Stream.empty());
      when(() => mockDb.insertRide(any())).thenAnswer((_) async => 1);

      await container.activityNotifier.startRide();
      await container.activityNotifier.saveAndStop();

      final state = container.activity;
      expect(state.status, RideStatus.idle);
      expect(state.distanceKm, 0.0);
      expect(state.elapsed, Duration.zero);
      expect(state.trackPoints, isEmpty);
      verify(() => mockDb.insertRide(any())).called(1);
    });
  });

  group('GPS position processing', () {
    test('should update speed, altitude and add track point on position event',
        () async {
      final positions = [_makePosition(lat: 51.500, lng: -0.090, speedMs: 5.0, altM: 10)];
      when(() => mockGps.requestPermission()).thenAnswer((_) async => true);
      when(() => mockGps.positionStream())
          .thenAnswer((_) => Stream.fromIterable(positions));

      await container.activityNotifier.startRide();
      // Let the stream deliver events.
      await Future<void>.delayed(Duration.zero);

      final state = container.activity;
      expect(state.trackPoints.length, 1);
      expect(state.speedKmh, closeTo(5.0 * 3.6, 0.01));
      expect(state.altitudeM, 10.0);
    });

    test('should accumulate distance across multiple positions', () async {
      // Two points ~111 m apart (1 second of lat)
      final positions = [
        _makePosition(lat: 51.500, lng: -0.090, speedMs: 8.0, altM: 10),
        _makePosition(lat: 51.501, lng: -0.090, speedMs: 8.0, altM: 12),
      ];
      when(() => mockGps.requestPermission()).thenAnswer((_) async => true);
      when(() => mockGps.positionStream())
          .thenAnswer((_) => Stream.fromIterable(positions));

      await container.activityNotifier.startRide();
      await Future<void>.delayed(Duration.zero);

      final state = container.activity;
      expect(state.trackPoints.length, 2);
      expect(state.distanceKm, greaterThan(0.0));
      expect(state.distanceKm, lessThan(0.5)); // ~111 m
    });

    test('should not accumulate distance for first position (no previous point)',
        () async {
      final positions = [
        _makePosition(lat: 51.500, lng: -0.090, speedMs: 5.0, altM: 10),
      ];
      when(() => mockGps.requestPermission()).thenAnswer((_) async => true);
      when(() => mockGps.positionStream())
          .thenAnswer((_) => Stream.fromIterable(positions));

      await container.activityNotifier.startRide();
      await Future<void>.delayed(Duration.zero);

      expect(container.activity.distanceKm, 0.0);
    });
  });

  group('isMoving', () {
    test('should be false when speed is below threshold', () {
      final state = const ActivityState(speedKmh: 0.3);
      expect(state.isMoving, isFalse);
    });

    test('should be true when speed exceeds threshold', () {
      final state = const ActivityState(speedKmh: 5.0);
      expect(state.isMoving, isTrue);
    });
  });
}

Position _makePosition({
  required double lat,
  required double lng,
  required double speedMs,
  required double altM,
}) {
  return Position(
    latitude: lat,
    longitude: lng,
    speed: speedMs,
    altitude: altM,
    timestamp: DateTime.now(),
    accuracy: 5,
    altitudeAccuracy: 5,
    headingAccuracy: 5,
    heading: 0,
    speedAccuracy: 1,
  );
}
