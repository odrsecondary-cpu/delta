import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../services/gps_service.dart';
import 'activity_state.dart';

class ActivityNotifier extends Notifier<ActivityState> {
  StreamSubscription<Position>? _bgLocationSub;
  StreamSubscription<Position>? _gpsSub;
  Timer? _ticker;

  static const _distanceCalc = Distance();

  @override
  ActivityState build() {
    ref.onDispose(() {
      _bgLocationSub?.cancel();
      _gpsSub?.cancel();
      _ticker?.cancel();
    });
    return const ActivityState();
  }

  /// Starts passive position tracking so the map reflects current location
  /// before a ride begins.
  Future<void> initLocation() async {
    if (_bgLocationSub != null) return;
    final gps = ref.read(gpsServiceProvider);
    final granted = await gps.requestPermission();
    if (!granted) {
      state = state.copyWith(permissionDenied: true);
      return;
    }
    _bgLocationSub = gps.positionStream().listen((pos) {
      state = state.copyWith(
        currentPosition: LatLng(pos.latitude, pos.longitude),
      );
    });
  }

  Future<void> startRide() async {
    _bgLocationSub?.cancel();
    _bgLocationSub = null;

    final gps = ref.read(gpsServiceProvider);
    final granted = await gps.requestPermission();
    if (!granted) {
      state = state.copyWith(permissionDenied: true);
      return;
    }
    state = state.copyWith(
      status: RideStatus.active,
      permissionDenied: false,
    );
    _startTicker();
    _gpsSub = gps.positionStream().listen(_onPosition);
  }

  void pauseRide() {
    _gpsSub?.pause();
    _ticker?.cancel();
    _ticker = null;
    state = state.copyWith(status: RideStatus.paused);
  }

  void resumeRide() {
    _gpsSub?.resume();
    _startTicker();
    state = state.copyWith(status: RideStatus.active);
  }

  /// Ends the ride and resets state. Caller is responsible for persisting
  /// the ride to the database before invoking this.
  void stopRide() {
    _gpsSub?.cancel();
    _gpsSub = null;
    _ticker?.cancel();
    _ticker = null;
    state = const ActivityState();
    initLocation();
  }

  void _onPosition(Position pos) {
    final newPoint = LatLng(pos.latitude, pos.longitude);
    final updatedPoints = [...state.trackPoints, newPoint];

    double addedKm = 0;
    if (state.trackPoints.isNotEmpty) {
      // Distance.call returns meters
      addedKm =
          _distanceCalc(state.trackPoints.last, newPoint) / 1000.0;
    }

    state = state.copyWith(
      speedKmh: pos.speed * 3.6, // m/s → km/h
      distanceKm: state.distanceKm + addedKm,
      altitudeM: pos.altitude,
      trackPoints: updatedPoints,
      currentPosition: newPoint,
    );
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }
}

final activityProvider =
    NotifierProvider<ActivityNotifier, ActivityState>(ActivityNotifier.new);
