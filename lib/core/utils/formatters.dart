abstract final class RideFormatters {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "32 min" or "1:01 h"
  static String duration(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '$h:${m.toString().padLeft(2, '0')} h';
    }
    return '${d.inMinutes} min';
  }

  /// "5.2" — caller renders the "km" unit label separately
  static String distanceValue(double km) => km.toStringAsFixed(1);

  /// "Mar 29"
  static String shortDate(DateTime dt) =>
      '${_shortMonths[dt.month - 1]} ${dt.day}';

  /// "24 March 2026"
  static String longDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  /// "9:30 AM"
  static String time12h(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  /// "March"
  static String monthName(DateTime dt) => _months[dt.month - 1];

  /// "2026"
  static String year(DateTime dt) => dt.year.toString();
}
