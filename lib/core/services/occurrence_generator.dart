import '../recurrence/frequency.dart';
import '../recurrence/recurrence_engine.dart';
import '../../data/database/app_database.dart';

class OccurrenceGeneratorService {
  final ExpensesDao _expensesDao;
  final ExpenseOccurrencesDao _occurrencesDao;

  OccurrenceGeneratorService(this._expensesDao, this._occurrencesDao);

  Future<void> generateForMonth(DateTime month) async {
    final rangeStart = DateTime(month.year, month.month, 1);
    final rangeEnd = DateTime(month.year, month.month + 1, 0);

    final allExpenses = await _expensesDao.getAllExpenses();
    for (final expense in allExpenses) {
      if (expense.frequency == null) continue;
      if (expense.endDate != null && expense.endDate!.isBefore(rangeStart)) continue;

      final frequency = Frequency.values.byName(expense.frequency!);
      final dueDates = computeDueDates(
        startDate: expense.startDate,
        frequency: frequency,
        endDate: expense.endDate,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
      );

      final existing = await _occurrencesDao.getOccurrencesByExpenseAndDateRange(
        expense.id,
        rangeStart,
        rangeEnd,
      );
      final existingDates = existing.map((o) => _day(o.date)).toSet();

      for (final date in dueDates) {
        if (!existingDates.contains(date)) {
          await _occurrencesDao.insertOccurrence(
            ExpenseOccurrencesCompanion.insert(expenseId: expense.id, date: date),
          );
        }
      }
    }
  }

  DateTime _day(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
