import 'package:drift/drift.dart';
import 'categories_table.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  DateTimeColumn get startDate => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get frequency => text().nullable()(); // null = one-off
  IntColumn get reminderDays => integer().nullable()(); // null = no reminder
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
