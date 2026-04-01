import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../models/ride.dart';
import '../../models/track_point.dart';
import '../../services/database_service.dart';
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
      startTime: DateTime.now(),
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

  /// Saves the completed ride to the database, then resets state.
  Future<void> saveAndStop() async {
    final s = state;
    final now = DateTime.now();
    final start = s.startTime ?? now;
    final movingTime = s.elapsed;
    final totalDuration = now.difference(start);
    final avgSpeed = movingTime.inSeconds > 0
        ? s.distanceKm / (movingTime.inSeconds / 3600.0)
        : 0.0;

    final ride = Ride(
      name: _autoName(start),
      startTime: start,
      totalDistance: s.distanceKm,
      avgSpeed: avgSpeed,
      maxSpeed: s.maxSpeedKmh,
      duration: totalDuration,
      movingTime: movingTime,
      elevationGain: s.elevationGain,
      trackPoints: s.trackPoints,
    );

    await ref.read(databaseServiceProvider).insertRide(ride);

    _gpsSub?.cancel();
    _gpsSub = null;
    _ticker?.cancel();
    _ticker = null;
    state = const ActivityState();
    initLocation();
  }

  static String _autoName(DateTime t) {
    final h = t.hour;
    if (h < 12) return 'Morning Ride';
    if (h < 17) return 'Afternoon Ride';
    return 'Evening Ride';
  }

  void _onPosition(Position pos) {
    final newLatLng = LatLng(pos.latitude, pos.longitude);
    final speedKmh = pos.speed * 3.6; // m/s → km/h

    double addedKm = 0;
    if (state.trackPoints.isNotEmpty) {
      addedKm =
          _distanceCalc(state.trackPoints.last.position, newLatLng) / 1000.0;
    }

    double addedGain = 0;
    if (state.trackPoints.isNotEmpty) {
      final diff = pos.altitude - state.altitudeM;
      if (diff > 0) addedGain = diff;
    }

    final newPoint = TrackPoint(
      position: newLatLng,
      speed: speedKmh,
      altitude: pos.altitude,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      speedKmh: speedKmh,
      maxSpeedKmh: speedKmh > state.maxSpeedKmh ? speedKmh : state.maxSpeedKmh,
      distanceKm: state.distanceKm + addedKm,
      altitudeM: pos.altitude,
      elevationGain: state.elevationGain + addedGain,
      trackPoints: [...state.trackPoints, newPoint],
      currentPosition: newLatLng,
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
