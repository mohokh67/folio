import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:folio/data/tables/app_settings_table.dart';
import 'package:folio/data/tables/categories_table.dart';
import 'package:folio/data/tables/expense_occurrences_table.dart';
import 'package:folio/data/tables/expenses_table.dart';

part 'app_database.g.dart';

// ── Categories DAO ────────────────────────────────────────────────────────

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Future<List<Category>> getAllCategories() => select(categories).get();
  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  Future<Category?> getCategoryById(int id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<bool> updateCategory(CategoriesCompanion entry) =>
      update(categories).replace(entry);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();
}

// ── Expenses DAO ──────────────────────────────────────────────────────────

@DriftAccessor(tables: [Expenses])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.db);

  Future<List<Expense>> getAllExpenses() => select(expenses).get();
  Stream<List<Expense>> watchAllExpenses() => select(expenses).watch();

  Future<List<Expense>> getExpensesByCategory(int categoryId) =>
      (select(expenses)..where((t) => t.categoryId.equals(categoryId))).get();

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<bool> updateExpense(ExpensesCompanion entry) =>
      update(expenses).replace(entry);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();
}

// ── Expense Occurrences DAO ───────────────────────────────────────────────

@DriftAccessor(tables: [ExpenseOccurrences])
class ExpenseOccurrencesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpenseOccurrencesDaoMixin {
  ExpenseOccurrencesDao(super.db);

  Future<List<ExpenseOccurrence>> getOccurrencesByExpense(int expenseId) =>
      (select(expenseOccurrences)
            ..where((t) => t.expenseId.equals(expenseId)))
          .get();

  Future<List<ExpenseOccurrence>> getOccurrencesByDateRange(
    DateTime from,
    DateTime to,
  ) =>
      (select(expenseOccurrences)
            ..where(
              (t) =>
                  t.date.isBiggerOrEqualValue(from) &
                  t.date.isSmallerOrEqualValue(to),
            ))
          .get();

  Stream<List<ExpenseOccurrence>> watchOccurrencesByExpense(int expenseId) =>
      (select(expenseOccurrences)
            ..where((t) => t.expenseId.equals(expenseId)))
          .watch();

  Future<int> insertOccurrence(ExpenseOccurrencesCompanion entry) =>
      into(expenseOccurrences).insert(entry);

  Future<bool> updateOccurrence(ExpenseOccurrencesCompanion entry) =>
      update(expenseOccurrences).replace(entry);

  Future<int> deleteOccurrence(int id) =>
      (delete(expenseOccurrences)..where((t) => t.id.equals(id))).go();
}

// ── App Settings DAO ──────────────────────────────────────────────────────

@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion(key: Value(key), value: Value(value)),
      );

  Future<int> deleteValue(String key) =>
      (delete(appSettings)..where((t) => t.key.equals(key))).go();
}

// ── Database ──────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [Categories, Expenses, ExpenseOccurrences, AppSettings],
  daos: [CategoriesDao, ExpensesDao, ExpenseOccurrencesDao, AppSettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'folio'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedCategories();
    },
  );

  Future<void> _seedCategories() async {
    const seeds = [
      (name: 'Housing', emoji: '🏠', color: 0xFF5C6BC0),
      (name: 'Transport', emoji: '🚗', color: 0xFF42A5F5),
      (name: 'Groceries', emoji: '🛒', color: 0xFF66BB6A),
      (name: 'Entertainment', emoji: '🎬', color: 0xFFAB47BC),
      (name: 'Health', emoji: '💊', color: 0xFFEF5350),
      (name: 'Subscriptions', emoji: '📱', color: 0xFF26C6DA),
      (name: 'Eating Out', emoji: '🍽', color: 0xFFFF7043),
      (name: 'Education', emoji: '📚', color: 0xFF29B6F6),
      (name: 'Clothing', emoji: '👕', color: 0xFFEC407A),
      (name: 'Work', emoji: '💼', color: 0xFF78909C),
      (name: 'Savings', emoji: '💰', color: 0xFFFFCA28),
      (name: 'Utilities', emoji: '🔧', color: 0xFF8D6E63),
    ];

    for (final seed in seeds) {
      await into(categories).insert(
        CategoriesCompanion.insert(
          name: seed.name,
          emoji: seed.emoji,
          color: seed.color,
        ),
      );
    }
  }
}
