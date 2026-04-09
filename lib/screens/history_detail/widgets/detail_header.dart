import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/ride.dart';
import '../../../screens/history/history_notifier.dart';

class DetailHeader extends ConsumerWidget {
  const DetailHeader({super.key, required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RideFormatters.longDate(ride.startTime),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Started at ${RideFormatters.time12h(ride.startTime)}',
                  style: const TextStyle(
                    color: AppColors.whiteMuted,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _DeleteButton(ride: ride),
        ],
      ),
    );
  }
}

class _DeleteButton extends ConsumerWidget {
  const _DeleteButton({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
      onPressed: () => _showDeleteDialog(context, ref),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete ride'),
        content: const Text('This ride will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(historyProvider.notifier).deleteRide(ride.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                context.pop();
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
