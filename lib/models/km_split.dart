class KmSplit {
  const KmSplit({
    required this.km,
    required this.speedKmh,
    required this.paceSeconds,
  });

  final int km;
  final double speedKmh; // km/h for this split
  final int paceSeconds; // seconds per km

  String get timeLabel {
    final m = paceSeconds ~/ 60;
    final s = paceSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get paceLabel => '$timeLabel /km';

  String get speedLabel => speedKmh.toStringAsFixed(1);
}
