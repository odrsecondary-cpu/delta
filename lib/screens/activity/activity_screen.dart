import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../history/history_notifier.dart';
import 'activity_notifier.dart';
import 'activity_state.dart';
import 'widgets/live_badge.dart';
import 'widgets/map_panel.dart';
import 'widgets/metric_card.dart';
import 'widgets/ride_controls.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityProvider.notifier).initLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final actState = ref.watch(activityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ActivityHeader(actState: actState),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const MapPanel(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (actState.permissionDenied)
              const _PermissionBanner(),
            _MetricsGrid(actState: actState),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: RideControls(
                onStopRequested: () => _confirmStop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmStop(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop Ride'),
        content: const Text('End and save this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.whiteMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Stop',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(activityProvider.notifier).saveAndStop();
      ref.invalidate(historyProvider);
    }
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({required this.actState});

  final ActivityState actState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Activity',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actState.isActive) LiveBadge(elapsed: actState.elapsed),
        ],
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: const Text(
        'Location permission required. Please enable it in system settings.',
        style: TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.actState});

  final ActivityState actState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          MetricCard(
            label: 'Speed',
            value: actState.speedKmh.toStringAsFixed(1),
            unit: 'km/h',
            highlighted: actState.isMoving || actState.status == RideStatus.paused,
            accentColor: actState.status == RideStatus.paused ? AppColors.orange : AppColors.green,
          ),
          MetricCard(
            label: 'Distance',
            value: actState.distanceKm.toStringAsFixed(2),
            unit: 'km',
          ),
          MetricCard(
            label: 'Time',
            value: _formatElapsed(actState.elapsed),
            unit: '',
          ),
          MetricCard(
            label: 'Altitude',
            value: actState.altitudeM.toStringAsFixed(0),
            unit: 'm',
          ),
        ],
      ),
    );
  }

  static String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
