import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ride.dart';
import '../../services/database_service.dart';

class HistoryNotifier extends AsyncNotifier<List<Ride>> {
  @override
  Future<List<Ride>> build() =>
      ref.read(databaseServiceProvider).getAllRides();

  Future<void> deleteRide(int id) async {
    await ref.read(databaseServiceProvider).deleteRide(id);
    ref.invalidateSelf();
  }

  Future<void> renameRide(int id, String name) async {
    await ref.read(databaseServiceProvider).updateRideName(id, name);
    ref.invalidateSelf();
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<Ride>>(HistoryNotifier.new);
