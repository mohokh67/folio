import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/calendar_providers.dart';
import '../../core/providers/settings_providers.dart';
import '../../data/database/app_database.dart';
import 'summary_calculator.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _currencySymbols = {
  'GBP': '£', 'USD': r'$', 'EUR': '€', 'CAD': r'CA$',
  'AUD': r'A$', 'JPY': '¥', 'CHF': 'Fr', 'INR': '₹',
  'SGD': r'S$', 'NZD': r'NZ$',
};

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(currentMonthProvider);
    final calendarAsync = ref.watch(calendarDataProvider);
    final currency = ref.watch(settingsRepositoryProvider).currency;
    final symbol = _currencySymbols[currency] ?? currency;
    final title = '${_monthNames[currentMonth.month - 1]} ${currentMonth.year}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: calendarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (occurrences) {
          if (occurrences.isEmpty) {
            return const Center(child: Text('No expenses this month.'));
          }
          final data = calculateSummary(occurrences);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProgressCard(data: data, symbol: symbol),
              const SizedBox(height: 16),
              _CategorySection(data: data, symbol: symbol),
              const SizedBox(height: 16),
              _UpcomingSection(data: data, symbol: symbol),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final SummaryData data;
  final String symbol;

  const _ProgressCard({required this.data, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = (data.paidFraction * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paid', style: TextStyle(color: cs.onSurfaceVariant)),
                Text('$pct%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: data.paidFraction,
                minHeight: 10,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AmountLabel(
                  label: 'Paid',
                  amount: '$symbol${data.totalPaid.toStringAsFixed(2)}',
                  color: Colors.green,
                ),
                _AmountLabel(
                  label: 'Remaining',
                  amount: '$symbol${data.totalUnpaid.toStringAsFixed(2)}',
                  color: cs.onSurface,
                  alignRight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountLabel extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final bool alignRight;

  const _AmountLabel({
    required this.label,
    required this.amount,
    required this.color,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final children = [
      Text(label,
          style: TextStyle(
              fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 2),
      Text(amount,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    ];
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _CategorySection extends StatelessWidget {
  final SummaryData data;
  final String symbol;

  const _CategorySection({required this.data, required this.symbol});

  @override
  Widget build(BuildContext context) {
    if (data.categoryBreakdown.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('By category',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: data.categoryBreakdown.map((cat) {
              final fraction = cat.total == 0 ? 0.0 : cat.paid / cat.total;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(cat.color).withAlpha(50),
                      child: Text(cat.emoji),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(cat.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              Text(
                                '$symbol${cat.paid.toStringAsFixed(2)} / $symbol${cat.total.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 4,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(cat.color)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  final SummaryData data;
  final String symbol;

  const _UpcomingSection({required this.data, required this.symbol});

  @override
  Widget build(BuildContext context) {
    if (data.upcomingUnpaid.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Text('All expenses paid this month!',
                  style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upcoming unpaid',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: data.upcomingUnpaid
                .map((o) => _UpcomingTile(o: o, symbol: symbol))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  final OccurrenceWithDetails o;
  final String symbol;

  const _UpcomingTile({required this.o, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final d = o.occurrence.date;
    final dateLabel = '${d.day}/${d.month}/${d.year}';
    final amount = o.occurrence.amount ?? o.expense.amount;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(o.category.color).withAlpha(50),
        child: Text(o.category.emoji),
      ),
      title: Text(o.expense.name),
      subtitle: Text(dateLabel),
      trailing: Text(
        '$symbol${amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
