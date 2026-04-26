import 'frequency.dart';

List<DateTime> computeDueDates({
  required DateTime startDate,
  required Frequency frequency,
  DateTime? endDate,
  required DateTime rangeStart,
  required DateTime rangeEnd,
}) {
  startDate = _dateOnly(startDate);
  rangeStart = _dateOnly(rangeStart);
  rangeEnd = _dateOnly(rangeEnd);
  if (endDate != null) endDate = _dateOnly(endDate);

  if (startDate.isAfter(rangeEnd)) return [];
  if (endDate != null && endDate.isBefore(rangeStart)) return [];

  final effectiveEnd = endDate != null
      ? (endDate.isBefore(rangeEnd) ? endDate : rangeEnd)
      : rangeEnd;

  final results = <DateTime>[];
  var step = 0;

  while (true) {
    final current = _nthOccurrence(startDate, frequency, step);
    if (current.isAfter(effectiveEnd)) break;
    if (!current.isBefore(rangeStart)) results.add(current);
    step++;
  }

  return results;
}

DateTime _nthOccurrence(DateTime start, Frequency freq, int n) {
  return switch (freq) {
    Frequency.daily => start.add(Duration(days: n)),
    Frequency.weekly => start.add(Duration(days: 7 * n)),
    Frequency.biWeekly => start.add(Duration(days: 14 * n)),
    Frequency.monthly => _addMonths(start, n),
    Frequency.biMonthly => _addMonths(start, 2 * n),
    Frequency.quarterly => _addMonths(start, 3 * n),
    Frequency.semiAnnually => _addMonths(start, 6 * n),
    Frequency.annually => _addMonths(start, 12 * n),
  };
}

DateTime _addMonths(DateTime date, int months) {
  final targetMonth = date.month + months;
  final year = date.year + (targetMonth - 1) ~/ 12;
  final month = (targetMonth - 1) % 12 + 1;
  final lastDay = _daysInMonth(year, month);
  final day = date.day > lastDay ? lastDay : date.day;
  return DateTime(year, month, day);
}

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
