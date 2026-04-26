import 'package:drift/drift.dart';
import 'expenses_table.dart';

class ExpenseOccurrences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get expenseId => integer().references(Expenses, #id)();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidAt => dateTime().nullable()();
  BoolColumn get isSkipped => boolean().withDefault(const Constant(false))();
}
