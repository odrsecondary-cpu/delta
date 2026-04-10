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
    _coords = widget.trackPoints.map((tp) => tp.position).toList();

    final speeds = widget.trackPoints.map((tp) => tp.speed).toList();
    _minSpeed = speeds.reduce(math.min);
    _maxSpeed = speeds.reduce(math.max);
    _speedPolylines = _buildSpeedPolylines(widget.trackPoints);
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
        // Speed legend — bottom, full width
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: _SpeedLegend(
                  minSpeed: _minSpeed,
                  maxSpeed: _maxSpeed,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}

// ---------------------------------------------------------------------------
// Speed legend overlay
// ---------------------------------------------------------------------------

class _SpeedLegend extends StatelessWidget {
  const _SpeedLegend({
    required this.minSpeed,
    required this.maxSpeed,
  });

  final double minSpeed;
  final double maxSpeed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${minSpeed.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 6,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: _gradientColors),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${maxSpeed.toStringAsFixed(0)} km/h',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
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

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 18, color: Colors.black87),
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
