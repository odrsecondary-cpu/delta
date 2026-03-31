import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class GpsService {
  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 3, // meters — skip tiny noise
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
