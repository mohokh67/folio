import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/data/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final categoriesDaoProvider = Provider<CategoriesDao>((ref) {
  return ref.watch(databaseProvider).categoriesDao;
});

final expensesDaoProvider = Provider<ExpensesDao>((ref) {
  return ref.watch(databaseProvider).expensesDao;
});

final expenseOccurrencesDaoProvider = Provider<ExpenseOccurrencesDao>((ref) {
  return ref.watch(databaseProvider).expenseOccurrencesDao;
});

final appSettingsDaoProvider = Provider<AppSettingsDao>((ref) {
  return ref.watch(databaseProvider).appSettingsDao;
});
