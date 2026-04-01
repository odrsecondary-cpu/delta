import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gamma/models/ride.dart';
import 'package:gamma/screens/history/history_notifier.dart';
import 'package:gamma/services/database_service.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

extension on ProviderContainer {
  HistoryNotifier get notifier => read(historyProvider.notifier);
  Future<List<Ride>> get rides => read(historyProvider.future);
}

void main() {
  late MockDatabaseService mockDb;
  late ProviderContainer container;

  final startTime = DateTime(2026, 3, 29, 9, 30);

  Ride makeRide(int id, String name) => Ride(
        id: id,
        name: name,
        startTime: startTime,
        totalDistance: 10.0,
        avgSpeed: 20.0,
        maxSpeed: 35.0,
        duration: const Duration(minutes: 30),
        movingTime: const Duration(minutes: 28),
        elevationGain: 50.0,
      );

  setUp(() {
    mockDb = MockDatabaseService();
    container = ProviderContainer(
      overrides: [databaseServiceProvider.overrideWithValue(mockDb)],
    );
  });

  tearDown(() => container.dispose());

  group('build', () {
    test('should load all rides from the database', () async {
      final rides = [makeRide(1, 'A'), makeRide(2, 'B')];
      when(() => mockDb.getAllRides()).thenAnswer((_) async => rides);

      final result = await container.rides;

      expect(result.map((r) => r.id), rides.map((r) => r.id));
      verify(() => mockDb.getAllRides()).called(1);
    });
  });

  group('deleteRide', () {
    test('should delete ride and reload the list', () async {
      when(() => mockDb.getAllRides())
          .thenAnswer((_) async => [makeRide(1, 'A'), makeRide(2, 'B')]);
      await container.rides; // trigger initial load

      when(() => mockDb.deleteRide(1)).thenAnswer((_) async {});
      when(() => mockDb.getAllRides()).thenAnswer((_) async => [makeRide(2, 'B')]);

      await container.notifier.deleteRide(1);
      final result = await container.rides;

      expect(result.length, 1);
      expect(result.first.id, 2);
      verify(() => mockDb.deleteRide(1)).called(1);
    });
  });

  group('renameRide', () {
    test('should rename ride and reload the list', () async {
      when(() => mockDb.getAllRides())
          .thenAnswer((_) async => [makeRide(1, 'Old name')]);
      await container.rides;

      when(() => mockDb.updateRideName(1, 'New name'))
          .thenAnswer((_) async {});
      when(() => mockDb.getAllRides())
          .thenAnswer((_) async => [makeRide(1, 'New name')]);

      await container.notifier.renameRide(1, 'New name');
      final result = await container.rides;

      expect(result.first.name, 'New name');
      verify(() => mockDb.updateRideName(1, 'New name')).called(1);
    });
  });
}
