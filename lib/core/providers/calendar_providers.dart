import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/occurrence_generator.dart';
import 'database_providers.dart';
import '../../data/database/app_database.dart';

final currentMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final occurrenceGeneratorProvider = Provider<OccurrenceGeneratorService>((ref) {
  return OccurrenceGeneratorService(
    ref.watch(expensesDaoProvider),
    ref.watch(expenseOccurrencesDaoProvider),
  );
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoriesDaoProvider).watchAllCategories();
});

final dayOccurrencesProvider =
    Provider.family<List<OccurrenceWithDetails>, DateTime>((ref, date) {
  return ref.watch(calendarDataProvider).maybeWhen(
    data: (all) => all.where((o) {
      final d = o.occurrence.date;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList(),
    orElse: () => [],
  );
});

// Runs the generator for current + adjacent months, then streams current month
final calendarDataProvider = StreamProvider<List<OccurrenceWithDetails>>((ref) async* {
  final month = ref.watch(currentMonthProvider);
  final generator = ref.read(occurrenceGeneratorProvider);
  final dao = ref.read(expenseOccurrencesDaoProvider);

  await generator.generateForMonth(DateTime(month.year, month.month - 1));
  await generator.generateForMonth(month);
  await generator.generateForMonth(DateTime(month.year, month.month + 1));

  final rangeStart = DateTime(month.year, month.month, 1);
  final rangeEnd = DateTime(month.year, month.month + 1, 0);
  yield* dao.watchOccurrencesWithDetailsByDateRange(rangeStart, rangeEnd);
});
