import 'package:drift/drift.dart';
import 'expenses_table.dart';

class ExpenseOccurrences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get expenseId => integer().references(Expenses, #id)();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real().nullable()();
  TextColumn get note => text().nullable()();
}
