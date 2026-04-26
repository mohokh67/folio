import '../../data/database/app_database.dart';

class CategorySummary {
  final String name;
  final String emoji;
  final int color;
  final double paid;
  final double total;

  const CategorySummary({
    required this.name,
    required this.emoji,
    required this.color,
    required this.paid,
    required this.total,
  });
}

class SummaryData {
  final double totalPaid;
  final double totalUnpaid;
  final List<CategorySummary> categoryBreakdown;
  final List<OccurrenceWithDetails> upcomingUnpaid;

  const SummaryData({
    required this.totalPaid,
    required this.totalUnpaid,
    required this.categoryBreakdown,
    required this.upcomingUnpaid,
  });

  double get paidFraction {
    final total = totalPaid + totalUnpaid;
    return total == 0 ? 0 : totalPaid / total;
  }
}

SummaryData calculateSummary(List<OccurrenceWithDetails> occurrences) {
  final active = occurrences.where((o) => !o.occurrence.isSkipped).toList();

  double totalPaid = 0;
  double totalUnpaid = 0;
  final Map<int, _CategoryAccumulator> byCategory = {};

  for (final o in active) {
    final amount = o.occurrence.amount ?? o.expense.amount;
    final catId = o.category.id;

    byCategory.putIfAbsent(
      catId,
      () => _CategoryAccumulator(
        name: o.category.name,
        emoji: o.category.emoji,
        color: o.category.color,
      ),
    );

    byCategory[catId]!.total += amount;
    if (o.occurrence.isPaid) {
      totalPaid += amount;
      byCategory[catId]!.paid += amount;
    } else {
      totalUnpaid += amount;
    }
  }

  final upcoming = active
      .where((o) => !o.occurrence.isPaid)
      .toList()
    ..sort((a, b) => a.occurrence.date.compareTo(b.occurrence.date));

  final breakdown = byCategory.values
      .map((a) => CategorySummary(
            name: a.name,
            emoji: a.emoji,
            color: a.color,
            paid: a.paid,
            total: a.total,
          ))
      .toList()
    ..sort((a, b) => b.total.compareTo(a.total));

  return SummaryData(
    totalPaid: totalPaid,
    totalUnpaid: totalUnpaid,
    categoryBreakdown: breakdown,
    upcomingUnpaid: upcoming,
  );
}

class _CategoryAccumulator {
  final String name;
  final String emoji;
  final int color;
  double paid = 0;
  double total = 0;

  _CategoryAccumulator({
    required this.name,
    required this.emoji,
    required this.color,
  });
}
