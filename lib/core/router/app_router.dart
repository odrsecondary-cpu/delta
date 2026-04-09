import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/activity/activity_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/history_detail/history_detail_screen.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../widgets/app_shell.dart';

final historyNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/activity',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activity',
                builder: (context, _) => const ActivityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: historyNavigatorKey,
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, _) => const HistoryScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return HistoryDetailScreen(rideId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, _) => const StatisticsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
