import 'package:drift/drift.dart';
import 'categories_table.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
