import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/recurrence/frequency.dart';
import 'package:folio/core/recurrence/recurrence_engine.dart';

void main() {
  group('computeDueDates', () {
    final jan1 = DateTime(2025, 1, 1);
    final jan31 = DateTime(2025, 1, 31);

    test('daily returns every day in range', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.daily,
        rangeStart: DateTime(2025, 1, 3),
        rangeEnd: DateTime(2025, 1, 5),
      );
      expect(dates, [DateTime(2025, 1, 3), DateTime(2025, 1, 4), DateTime(2025, 1, 5)]);
    });

    test('weekly returns correct dates', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.weekly,
        rangeStart: DateTime(2025, 1, 1),
        rangeEnd: DateTime(2025, 1, 22),
      );
      expect(dates, [jan1, DateTime(2025, 1, 8), DateTime(2025, 1, 15), DateTime(2025, 1, 22)]);
    });

    test('biWeekly returns every 2 weeks', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.biWeekly,
        rangeStart: jan1,
        rangeEnd: DateTime(2025, 1, 31),
      );
      expect(dates, [jan1, DateTime(2025, 1, 15), DateTime(2025, 1, 29)]);
    });

    test('monthly returns same day each month', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.monthly,
        rangeStart: jan1,
        rangeEnd: DateTime(2025, 3, 31),
      );
      expect(dates, [jan1, DateTime(2025, 2, 1), DateTime(2025, 3, 1)]);
    });

    test('monthly clamps day for short months (Jan 31 -> Feb 28)', () {
      final dates = computeDueDates(
        startDate: jan31,
        frequency: Frequency.monthly,
        rangeStart: jan31,
        rangeEnd: DateTime(2025, 3, 31),
      );
      expect(dates, [jan31, DateTime(2025, 2, 28), DateTime(2025, 3, 31)]);
    });

    test('biMonthly returns every 2 months', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.biMonthly,
        rangeStart: jan1,
        rangeEnd: DateTime(2025, 5, 31),
      );
      expect(dates, [jan1, DateTime(2025, 3, 1), DateTime(2025, 5, 1)]);
    });

    test('quarterly returns every 3 months', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.quarterly,
        rangeStart: jan1,
        rangeEnd: DateTime(2025, 7, 31),
      );
      expect(dates, [jan1, DateTime(2025, 4, 1), DateTime(2025, 7, 1)]);
    });

    test('semiAnnually returns every 6 months', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.semiAnnually,
        rangeStart: jan1,
        rangeEnd: DateTime(2025, 12, 31),
      );
      expect(dates, [jan1, DateTime(2025, 7, 1)]);
    });

    test('annually returns same day next year', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.annually,
        rangeStart: jan1,
        rangeEnd: DateTime(2026, 1, 31),
      );
      expect(dates, [jan1, DateTime(2026, 1, 1)]);
    });

    test('respects endDate — no dates after it', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.monthly,
        endDate: DateTime(2025, 2, 15),
        rangeStart: jan1,
        rangeEnd: DateTime(2025, 3, 31),
      );
      expect(dates, [jan1, DateTime(2025, 2, 1)]);
    });

    test('returns empty when startDate is after rangeEnd', () {
      final dates = computeDueDates(
        startDate: DateTime(2025, 4, 1),
        frequency: Frequency.monthly,
        rangeStart: jan1,
        rangeEnd: DateTime(2025, 3, 31),
      );
      expect(dates, isEmpty);
    });

    test('returns empty when endDate is before rangeStart', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.monthly,
        endDate: DateTime(2024, 12, 31),
        rangeStart: DateTime(2025, 1, 1),
        rangeEnd: DateTime(2025, 3, 31),
      );
      expect(dates, isEmpty);
    });

    test('same-day start is included when in range', () {
      final dates = computeDueDates(
        startDate: jan1,
        frequency: Frequency.monthly,
        rangeStart: jan1,
        rangeEnd: jan1,
      );
      expect(dates, [jan1]);
    });
  });
}
