import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';

class GpsService {
  static final _locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 3, // meters — skip tiny noise
    foregroundNotificationConfig: ForegroundNotificationConfig(
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

  Stream<Position> positionStream() =>
      Geolocator.getPositionStream(locationSettings: _locationSettings);
}

final gpsServiceProvider = Provider<GpsService>((_) => GpsService());
