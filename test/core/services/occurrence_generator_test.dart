import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/recurrence/frequency.dart';
import 'package:folio/core/services/occurrence_generator.dart';
import 'package:folio/data/database/app_database.dart';
import 'package:drift/drift.dart' show Value;

void main() {
  late AppDatabase db;
  late OccurrenceGeneratorService generator;
  late int categoryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    generator = OccurrenceGeneratorService(db.expensesDao, db.expenseOccurrencesDao);
    categoryId = await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(name: 'Test', emoji: '🔵', color: 0xFF0000FF),
    );
  });

  tearDown(() => db.close());

  Future<int> insertRecurringExpense({
    required DateTime startDate,
    required String frequency,
    DateTime? endDate,
  }) =>
      db.expensesDao.insertExpense(ExpensesCompanion.insert(
        categoryId: categoryId,
        name: 'Rent',
        amount: 1000.0,
        startDate: Value(startDate),
        frequency: Value(frequency),
        endDate: Value(endDate),
      ));

  test('generates monthly occurrence in range', () async {
    final expenseId = await insertRecurringExpense(
      startDate: DateTime(2025, 1, 1),
      frequency: Frequency.monthly.name,
    );
    await generator.generateForMonth(DateTime(2025, 1));
    final occs = await db.expenseOccurrencesDao.getOccurrencesByExpenseAndDateRange(
      expenseId, DateTime(2025, 1, 1), DateTime(2025, 1, 31),
    );
    expect(occs.length, 1);
    expect(occs.first.date, DateTime(2025, 1, 1));
  });

  test('does not duplicate occurrences on repeated calls', () async {
    final expenseId = await insertRecurringExpense(
      startDate: DateTime(2025, 1, 1),
      frequency: Frequency.monthly.name,
    );
    await generator.generateForMonth(DateTime(2025, 1));
    await generator.generateForMonth(DateTime(2025, 1));
    final occs = await db.expenseOccurrencesDao.getOccurrencesByExpenseAndDateRange(
      expenseId, DateTime(2025, 1, 1), DateTime(2025, 1, 31),
    );
    expect(occs.length, 1);
  });

  test('skips expense past its endDate', () async {
    final expenseId = await insertRecurringExpense(
      startDate: DateTime(2025, 1, 1),
      frequency: Frequency.monthly.name,
      endDate: DateTime(2025, 1, 31),
    );
    await generator.generateForMonth(DateTime(2025, 3));
    final occs = await db.expenseOccurrencesDao.getOccurrencesByExpenseAndDateRange(
      expenseId, DateTime(2025, 3, 1), DateTime(2025, 3, 31),
    );
    expect(occs, isEmpty);
  });

  test('one-off expenses (null frequency) are not generated', () async {
    final expenseId = await db.expensesDao.insertExpense(ExpensesCompanion.insert(
      categoryId: categoryId,
      name: 'One-off',
      amount: 50.0,
      startDate: Value(DateTime(2025, 1, 15)),
    ));
    await generator.generateForMonth(DateTime(2025, 1));
    final occs = await db.expenseOccurrencesDao.getOccurrencesByExpenseAndDateRange(
      expenseId, DateTime(2025, 1, 1), DateTime(2025, 1, 31),
    );
    expect(occs, isEmpty);
  });

  test('weekly expense generates multiple occurrences', () async {
    final expenseId = await insertRecurringExpense(
      startDate: DateTime(2025, 1, 1),
      frequency: Frequency.weekly.name,
    );
    await generator.generateForMonth(DateTime(2025, 1));
    final occs = await db.expenseOccurrencesDao.getOccurrencesByExpenseAndDateRange(
      expenseId, DateTime(2025, 1, 1), DateTime(2025, 1, 31),
    );
    expect(occs.length, 5); // Jan 1, 8, 15, 22, 29
  });
}
