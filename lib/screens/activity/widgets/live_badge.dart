import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Animated LIVE badge shown in the Activity header during an active ride.
/// The green dot pulses to indicate an active GPS session.
/// When [paused] is true, the dot stops pulsing and the text turns orange with strikethrough.
class LiveBadge extends StatefulWidget {
  const LiveBadge({super.key, required this.elapsed, this.paused = false});

  final Duration elapsed;
  final bool paused;

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    if (!widget.paused) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(LiveBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paused && !oldWidget.paused) {
      _pulse.stop();
    } else if (!widget.paused && oldWidget.paused) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.paused ? AppColors.orange : AppColors.green;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: _opacity,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'LIVE',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            decoration: widget.paused ? TextDecoration.lineThrough : null,
            decorationColor: AppColors.orange,
            decorationThickness: 2,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatElapsed(widget.elapsed),
          style: const TextStyle(
            color: AppColors.whiteMuted,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  static String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
