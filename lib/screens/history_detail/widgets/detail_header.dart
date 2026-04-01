import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/ride.dart';
import '../../../screens/history/history_notifier.dart';
import '../ride_detail_provider.dart';

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
          _OverflowMenu(ride: ride),
        ],
      ),
    );
  }
}

class _OverflowMenu extends ConsumerWidget {
  const _OverflowMenu({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_Action>(
      icon: const Icon(Icons.more_vert, color: AppColors.whiteMuted),
      color: AppColors.surface,
      onSelected: (action) {
        switch (action) {
          case _Action.rename:
            _showRenameDialog(context, ref);
          case _Action.delete:
            _showDeleteDialog(context, ref);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _Action.rename,
          child: Text('Rename', style: TextStyle(color: AppColors.white)),
        ),
        const PopupMenuItem(
          value: _Action.delete,
          child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ride.name);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename ride'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.greenBright),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.greenBright),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(historyProvider.notifier)
                    .renameRide(ride.id, name);
                ref.invalidate(rideDetailProvider(ride.id));
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.greenBright),
            ),
          ),
        ],
      ),
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
              await ref
                  .read(historyProvider.notifier)
                  .deleteRide(ride.id);
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

enum _Action { rename, delete }
