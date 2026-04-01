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
          height: 160,
          child: trackPoints.isEmpty
              ? _NoDataPlaceholder()
              : _RouteMap(trackPoints: trackPoints),
        ),
      ),
    );
  }
}

class _RouteMap extends StatelessWidget {
  const _RouteMap({required this.trackPoints});

  final List<TrackPoint> trackPoints;

  @override
  Widget build(BuildContext context) {
    final coords = trackPoints.map((tp) => tp.position).toList();
    final start = coords.first;
    final end = coords.last;
    final segments = _buildSegments(trackPoints);

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: coords,
          padding: const EdgeInsets.all(24),
        ),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
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
            for (final seg in segments)
              if (seg.length >= 2)
                Polyline(
                  points: seg,
                  color: AppColors.green,
                  strokeWidth: 2.5,
                ),
          ],
        ),
        CircleLayer(
          circles: [
            // Start: muted white filled circle
            CircleMarker(
              point: start,
              radius: 6,
              color: AppColors.whiteMuted,
              borderColor: AppColors.white,
              borderStrokeWidth: 1,
            ),
            // End: glow halo
            CircleMarker(
              point: end,
              radius: 12,
              color: AppColors.green.withValues(alpha: 0.25),
              borderColor: Colors.transparent,
              borderStrokeWidth: 0,
            ),
            // End: filled green dot
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
    );
  }

  /// Split a flat track-point list into polyline segments using the
  /// [TrackPoint.segmentBreak] flag written by the recorder on resume.
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
