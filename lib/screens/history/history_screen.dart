import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/ride.dart';
import 'history_notifier.dart';
import 'widgets/month_section.dart';
import 'widgets/total_bar.dart';

// ── Month grouping ────────────────────────────────────────────────────────────

extension _RideGrouping on List<Ride> {
  List<({DateTime month, List<Ride> rides})> groupByMonth() {
    final groups = <DateTime, List<Ride>>{};
    for (final ride in this) {
      final key = DateTime(ride.startTime.year, ride.startTime.month);
      (groups[key] ??= []).add(ride);
    }
    final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.map((k) => (month: k, rides: groups[k]!)).toList();
  }
}

String _monthKey(DateTime dt) => '${dt.year}-${dt.month}';

// ── Screen ────────────────────────────────────────────────────────────────────

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final Set<String> _collapsed = {};
  bool _initialized = false;

  void _initCollapsed(List<({DateTime month, List<Ride> rides})> groups) {
    if (_initialized) return;
    _initialized = true;
    final now = DateTime.now();
    final currentKey = _monthKey(DateTime(now.year, now.month));
    for (final g in groups) {
      if (_monthKey(g.month) != currentKey) {
        _collapsed.add(_monthKey(g.month));
      }
    }
  }

  void _toggleSection(DateTime month) {
    setState(() {
      final key = _monthKey(month);
      if (_collapsed.contains(key)) {
        _collapsed.remove(key);
      } else {
        _collapsed.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ridesAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HistoryHeader(),
            Expanded(
              child: ridesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.green),
                ),
                error: (_, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Could not load rides',
                        style: TextStyle(color: AppColors.whiteMuted),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref.invalidate(historyProvider),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: AppColors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (rides) {
                  if (rides.isNotEmpty) _initCollapsed(rides.groupByMonth());
                  return rides.isEmpty
                      ? const _EmptyState()
                      : _RideList(
                          rides: rides,
                          collapsed: _collapsed,
                          onToggle: _toggleSection,
                          onRideTap: (ride) =>
                              context.push('/history/${ride.id}'),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── List + pinned total bar ───────────────────────────────────────────────────

class _RideList extends StatelessWidget {
  const _RideList({
    required this.rides,
    required this.collapsed,
    required this.onToggle,
    required this.onRideTap,
  });

  final List<Ride> rides;
  final Set<String> collapsed;
  final ValueChanged<DateTime> onToggle;
  final ValueChanged<Ride> onRideTap;

  @override
  Widget build(BuildContext context) {
    final groups = rides.groupByMonth();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: groups.length,
            itemBuilder: (_, i) {
              final group = groups[i];
              return MonthSection(
                key: ValueKey(_monthKey(group.month)),
                month: group.month,
                rides: group.rides,
                isCollapsed: collapsed.contains(_monthKey(group.month)),
                onToggle: () => onToggle(group.month),
                onRideTap: onRideTap,
              );
            },
          ),
        ),
        TotalBar(rides: rides),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        'History',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_bike_outlined,
            size: 48,
            color: AppColors.whiteDim,
          ),
          SizedBox(height: 16),
          Text(
            'No rides yet',
            style: TextStyle(
              color: AppColors.whiteMuted,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Start a ride from the Activity screen',
            style: TextStyle(color: AppColors.whiteDim, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
