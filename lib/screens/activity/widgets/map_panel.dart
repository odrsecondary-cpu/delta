import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../activity_notifier.dart';

/// Full-width map panel showing the live GPS route and current position.
class MapPanel extends ConsumerStatefulWidget {
  const MapPanel({super.key});

  @override
  ConsumerState<MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends ConsumerState<MapPanel> {
  final _mapController = MapController();

  // Default center — used before first GPS fix.
  static const _defaultCenter = LatLng(52.0, 20.0);
  static const _defaultZoom = 15.0;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actState = ref.watch(activityProvider);

    // Pan map to follow rider as new positions arrive.
    ref.listen(
      activityProvider.select((s) => s.currentPosition),
      (_, next) {
        if (next != null && mounted) {
          _mapController.move(next, _mapController.camera.zoom);
        }
      },
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: actState.currentPosition ?? _defaultCenter,
            initialZoom: _defaultZoom,
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
            if (actState.trackPoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: actState.trackPoints,
                    color: AppColors.green,
                    strokeWidth: 3,
                  ),
                ],
              ),
            if (actState.currentPosition != null)
              CircleLayer(
                circles: [
                  // Halo
                  CircleMarker(
                    point: actState.currentPosition!,
                    radius: 18,
                    color: AppColors.green.withValues(alpha: 0.18),
                    borderColor: Colors.transparent,
                    borderStrokeWidth: 0,
                  ),
                  // Position dot
                  CircleMarker(
                    point: actState.currentPosition!,
                    radius: 8,
                    color: AppColors.green,
                    borderColor: Colors.white.withValues(alpha: 0.85),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
          ],
        ),
        Positioned(
          top: 10,
          right: 10,
          child: _ZoomControls(mapController: _mapController),
        ),
      ],
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.mapController});

  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(
            icon: Icons.add,
            onTap: () => mapController.move(
              mapController.camera.center,
              mapController.camera.zoom + 1,
            ),
          ),
          Container(height: 0.5, color: Colors.black12),
          _ZoomButton(
            icon: Icons.remove,
            onTap: () => mapController.move(
              mapController.camera.center,
              mapController.camera.zoom - 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}
