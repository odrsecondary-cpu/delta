import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/track_point.dart';

class DetailMapPanel extends StatelessWidget {
  const DetailMapPanel({super.key, required this.trackPoints});

  final List<TrackPoint> trackPoints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 260,
          child: trackPoints.isEmpty
              ? _NoDataPlaceholder()
              : _RouteMap(trackPoints: trackPoints),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Heatmap gradient — 6 stops, blue → cyan → green → yellow → orange → red
// ---------------------------------------------------------------------------

const _gradientColors = [
  Color(0xFF2979FF), // 0.00 — blue
  Color(0xFF00B0FF), // 0.20 — cyan
  Color(0xFF00E676), // 0.40 — green
  Color(0xFFFFD600), // 0.60 — yellow
  Color(0xFFFF6D00), // 0.80 — orange
  Color(0xFFFF1744), // 1.00 — red
];

Color _speedColor(double t) {
  final stops = _gradientColors.length - 1;
  final scaled = t.clamp(0.0, 1.0) * stops;
  final lo = scaled.floor().clamp(0, stops - 1);
  final hi = lo + 1;
  return Color.lerp(_gradientColors[lo], _gradientColors[hi], scaled - lo)!;
}

// ---------------------------------------------------------------------------
// Douglas–Peucker simplification (respects segmentBreak boundaries)
// ---------------------------------------------------------------------------

/// Perpendicular distance from [p] to the line defined by [a]→[b],
/// computed in degree-space (good enough for small GPS segments).
double _perpendicularDistance(LatLng p, LatLng a, LatLng b) {
  final dx = b.longitude - a.longitude;
  final dy = b.latitude - a.latitude;

  if (dx == 0 && dy == 0) {
    final dLat = p.latitude - a.latitude;
    final dLng = p.longitude - a.longitude;
    return math.sqrt(dLat * dLat + dLng * dLng);
  }

  final t = ((p.longitude - a.longitude) * dx + (p.latitude - a.latitude) * dy) /
      (dx * dx + dy * dy);
  final projLat = a.latitude + t * dy;
  final projLng = a.longitude + t * dx;
  final dLat = p.latitude - projLat;
  final dLng = p.longitude - projLng;
  return math.sqrt(dLat * dLat + dLng * dLng);
}

List<TrackPoint> _dpSimplify(List<TrackPoint> pts, double epsilon) {
  if (pts.length <= 2) return List.of(pts);

  double maxDist = 0;
  int maxIdx = 0;
  final start = pts.first.position;
  final end = pts.last.position;

  for (int i = 1; i < pts.length - 1; i++) {
    final d = _perpendicularDistance(pts[i].position, start, end);
    if (d > maxDist) {
      maxDist = d;
      maxIdx = i;
    }
  }

  if (maxDist > epsilon) {
    final left = _dpSimplify(pts.sublist(0, maxIdx + 1), epsilon);
    final right = _dpSimplify(pts.sublist(maxIdx), epsilon);
    return [...left.take(left.length - 1), ...right];
  }

  return [pts.first, pts.last];
}

/// Splits track by [segmentBreak], simplifies each sub-segment independently,
/// then reassembles. Epsilon is in decimal degrees (~0.00005° ≈ 5 m).
List<TrackPoint> _simplifyRoute(List<TrackPoint> pts, {double epsilon = 0.00005}) {
  if (pts.length <= 2) return pts;

  final result = <TrackPoint>[];
  var segStart = 0;

  for (int i = 1; i <= pts.length; i++) {
    final atEnd = i == pts.length;
    final atBreak = !atEnd && pts[i].segmentBreak;

    if (atEnd || atBreak) {
      result.addAll(_dpSimplify(pts.sublist(segStart, i), epsilon));
      segStart = i;
    }
  }

  return result;
}

// ---------------------------------------------------------------------------
// Map widget
// ---------------------------------------------------------------------------

class _RouteMap extends StatefulWidget {
  const _RouteMap({required this.trackPoints});

  final List<TrackPoint> trackPoints;

  @override
  State<_RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<_RouteMap> {
  final _mapController = MapController();

  late final List<LatLng> _coords;
  late final List<Polyline> _speedPolylines;
  late final double _minSpeed;
  late final double _maxSpeed;
  @override
  void initState() {
    super.initState();
    final simplified = _simplifyRoute(widget.trackPoints);
    _coords = simplified.map((tp) => tp.position).toList();

    final speeds = simplified.map((tp) => tp.speed).toList();
    _minSpeed = speeds.reduce(math.min);
    _maxSpeed = speeds.reduce(math.max);
    _speedPolylines = _buildSpeedPolylines(simplified);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitRoute() {
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: _coords,
        padding: const EdgeInsets.all(24),
      ),
    );
  }

  List<Polyline> _buildSpeedPolylines(List<TrackPoint> points) {
    if (points.length < 2) return [];
    final speedRange = _maxSpeed - _minSpeed;
    final polylines = <Polyline>[];

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      if (next.segmentBreak) continue;

      final avgSpeed = (current.speed + next.speed) / 2;
      final t =
          speedRange > 0
              ? ((avgSpeed - _minSpeed) / speedRange).clamp(0.0, 1.0)
              : 0.5;

      polylines.add(Polyline(
        points: [current.position, next.position],
        color: _speedColor(t),
        strokeWidth: 3.5,
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      ));
    }
    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    final start = _coords.first;
    final end = _coords.last;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: _coords,
              padding: const EdgeInsets.all(24),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.gamma',
            ),
            PolylineLayer(polylines: _speedPolylines),
            CircleLayer(
              circles: [
                // Start — green
                CircleMarker(
                  point: start,
                  radius: 7,
                  color: AppColors.green,
                  borderColor: Colors.white,
                  borderStrokeWidth: 1.5,
                ),
                // End — red glow + dot
                CircleMarker(
                  point: end,
                  radius: 13,
                  color: const Color(0xFFFF1744).withValues(alpha: 0.22),
                  borderColor: Colors.transparent,
                  borderStrokeWidth: 0,
                ),
                CircleMarker(
                  point: end,
                  radius: 7,
                  color: const Color(0xFFFF1744),
                  borderColor: Colors.white,
                  borderStrokeWidth: 1.5,
                ),
              ],
            ),
          ],
        ),
        // Map controls — top right
        Positioned(
          top: 10,
          right: 10,
          child: _MapControls(
            mapController: _mapController,
            onFitRoute: _fitRoute,
          ),
        ),
      ],
    );
  }

}

// ---------------------------------------------------------------------------
// Map controls
// ---------------------------------------------------------------------------

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.mapController,
    required this.onFitRoute,
  });

  final MapController mapController;
  final VoidCallback onFitRoute;

  static final _buttonDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: _buttonDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ControlButton(
                icon: Icons.add,
                onTap: () => mapController.move(
                  mapController.camera.center,
                  mapController.camera.zoom + 1,
                ),
              ),
              Container(height: 0.5, color: Colors.black12),
              _ControlButton(
                icon: Icons.remove,
                onTap: () => mapController.move(
                  mapController.camera.center,
                  mapController.camera.zoom - 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: _buttonDecoration,
          child: _ControlButton(
            icon: Icons.gps_fixed,
            onTap: onFitRoute,
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatefulWidget {
  const _ControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.78).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(widget.icon, size: 18, color: Colors.black87),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// No data placeholder
// ---------------------------------------------------------------------------

class _NoDataPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Text(
          'No GPS data',
          style: TextStyle(color: AppColors.whiteDim, fontSize: 12),
        ),
      ),
    );
  }
}
