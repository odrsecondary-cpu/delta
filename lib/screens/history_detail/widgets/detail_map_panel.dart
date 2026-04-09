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

class _RouteMap extends StatefulWidget {
  const _RouteMap({required this.trackPoints});

  final List<TrackPoint> trackPoints;

  @override
  State<_RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<_RouteMap> {
  final _mapController = MapController();

  late final List<LatLng> _coords;
  late final List<List<LatLng>> _segments;

  @override
  void initState() {
    super.initState();
    _coords = widget.trackPoints.map((tp) => tp.position).toList();
    _segments = _buildSegments(widget.trackPoints);
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
            PolylineLayer(
              polylines: [
                for (final seg in _segments)
                  if (seg.length >= 2)
                    Polyline(
                      points: seg,
                      color: AppColors.green,
                      strokeWidth: 3,
                    ),
              ],
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: start,
                  radius: 6,
                  color: AppColors.whiteMuted,
                  borderColor: AppColors.white,
                  borderStrokeWidth: 1,
                ),
                CircleMarker(
                  point: end,
                  radius: 12,
                  color: AppColors.green.withValues(alpha: 0.25),
                  borderColor: Colors.transparent,
                  borderStrokeWidth: 0,
                ),
                CircleMarker(
                  point: end,
                  radius: 6,
                  color: AppColors.green,
                  borderColor: Colors.transparent,
                  borderStrokeWidth: 0,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                _labelMarker(start, 'Start', AppColors.whiteMuted),
                _labelMarker(end, 'End', AppColors.green),
              ],
            ),
          ],
        ),
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

  List<List<LatLng>> _buildSegments(List<TrackPoint> points) {
    if (points.isEmpty) return [];
    final segments = <List<LatLng>>[];
    var current = <LatLng>[points.first.position];
    for (final tp in points.skip(1)) {
      if (tp.segmentBreak) {
        segments.add(current);
        current = [tp.position];
      } else {
        current.add(tp.position);
      }
    }
    segments.add(current);
    return segments;
  }

  Marker _labelMarker(LatLng point, String label, Color color) {
    return Marker(
      point: point,
      width: 40,
      height: 20,
      alignment: const Alignment(0, -3.2),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

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
