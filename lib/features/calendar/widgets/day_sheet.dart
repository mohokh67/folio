import 'package:flutter/material.dart';
import '../../../data/database/app_database.dart';

const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];
const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _currencySymbols = {
  'GBP': '£', 'USD': r'$', 'EUR': '€', 'CAD': r'CA$',
  'AUD': r'A$', 'JPY': '¥', 'CHF': 'Fr', 'INR': '₹',
  'SGD': r'S$', 'NZD': r'NZ$',
};

class DaySheet extends StatelessWidget {
  final DateTime date;
  final List<OccurrenceWithDetails> occurrences;
  final String currency;
  final VoidCallback onAdd;

  const DaySheet({
    super.key,
    required this.date,
    required this.occurrences,
    required this.currency,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = _currencySymbols[currency] ?? currency;
    final label =
        '${_weekdayNames[date.weekday - 1]}, ${date.day} ${_monthNames[date.month - 1]} ${date.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (occurrences.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No expenses on this day.')),
            )
          else
            ...occurrences.map((o) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Color(o.category.color).withAlpha(50),
                    child: Text(o.category.emoji),
                  ),
                  title: Text(o.expense.name),
                  subtitle: Text(o.category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$symbol${(o.occurrence.amount ?? o.expense.amount).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (o.occurrence.isPaid)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                        ),
                    ],
                  ),
                )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add expense'),
            ),
          ),
        ],
      ),
    );
  }
}
