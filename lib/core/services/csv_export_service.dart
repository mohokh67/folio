import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/database/app_database.dart';

class CsvExportService {
  Future<void> export(ExpenseOccurrencesDao dao, String currency) async {
    final rows = await dao.getAllOccurrencesWithDetails();

    final buffer = StringBuffer();
    buffer.writeln('Name,Category,Amount,Due Date,Status,Paid Date');

    for (final r in rows) {
      final amount = (r.occurrence.amount ?? r.expense.amount).toStringAsFixed(2);
      final dueDate = _fmtDate(r.occurrence.date);
      final status = r.occurrence.isSkipped
          ? 'skipped'
          : r.occurrence.isPaid
              ? 'paid'
              : 'unpaid';
      final paidDate = r.occurrence.paidAt != null
          ? _fmtDate(r.occurrence.paidAt!)
          : '';
      buffer.writeln(
        '${_escape(r.expense.name)},${_escape(r.category.name)},$amount,$dueDate,$status,$paidDate',
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/folio_export.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Folio expense export',
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _escape(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}
