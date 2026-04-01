import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../activity_notifier.dart';
import '../activity_state.dart';

/// Pause/Resume + Stop buttons shown at the bottom of the Activity screen.
class RideControls extends ConsumerWidget {
  const RideControls({super.key, required this.onStopRequested});

  /// Called when the user taps Stop. The parent screen handles the
  /// confirmation dialog and then calls the notifier.
  final VoidCallback onStopRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(activityProvider.select((s) => s.status));
    final notifier = ref.read(activityProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: _PrimaryButton(status: status, notifier: notifier),
        ),
        if (status != RideStatus.idle) ...[
          const SizedBox(width: 12),
          _StopButton(onPressed: onStopRequested),
        ],
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.status, required this.notifier});

  final RideStatus status;
  final ActivityNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      RideStatus.idle => 'Start Ride',
      RideStatus.active => 'Pause',
      RideStatus.paused => 'Resume',
    };

    void onPressed() {
      switch (status) {
        case RideStatus.idle:
          notifier.startRide();
        case RideStatus.active:
          notifier.pauseRide();
        case RideStatus.paused:
          notifier.resumeRide();
      }
    }

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB71C1C),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Icon(Icons.stop_rounded, size: 26),
      ),
    );
  }
}
