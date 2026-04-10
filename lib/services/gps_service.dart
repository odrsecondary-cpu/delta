import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';

class GpsService {
  // Pre-ride: just show current position on map, no foreground service needed.
  static final _previewSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );

  // Active ride: foreground service keeps GPS alive with screen off.
  static final _rideSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 3,
    foregroundNotificationConfig: const ForegroundNotificationConfig(
      notificationTitle: 'Gamma',
      notificationText: 'Recording your ride in the background',
      enableWakeLock: true,
    ),
  );

  Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Stream<Position> previewStream() =>
      Geolocator.getPositionStream(locationSettings: _previewSettings);

  Stream<Position> rideStream() =>
      Geolocator.getPositionStream(locationSettings: _rideSettings);
}

final gpsServiceProvider = Provider<GpsService>((_) => GpsService());
