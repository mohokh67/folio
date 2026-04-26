import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/calendar_providers.dart';
import '../../../core/providers/database_providers.dart';
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

class DaySheet extends ConsumerWidget {
  final DateTime date;
  final String currency;
  final VoidCallback onAdd;

  const DaySheet({
    super.key,
    required this.date,
    required this.currency,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occurrences = ref.watch(dayOccurrencesProvider(date));
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
            ...occurrences.map((o) => _OccurrenceTile(
              o: o,
              symbol: symbol,
              onTogglePaid: () => _togglePaid(ref, o),
              onToggleSkip: () => _toggleSkip(ref, o),
              onEditAmount: () => _editAmount(context, ref, o),
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

  Future<void> _togglePaid(WidgetRef ref, OccurrenceWithDetails o) {
    final dao = ref.read(expenseOccurrencesDaoProvider);
    return dao.togglePaid(o.occurrence.id, !o.occurrence.isPaid);
  }

  Future<void> _toggleSkip(WidgetRef ref, OccurrenceWithDetails o) {
    final dao = ref.read(expenseOccurrencesDaoProvider);
    return dao.toggleSkipped(o.occurrence.id, !o.occurrence.isSkipped);
  }

  Future<void> _editAmount(
    BuildContext context,
    WidgetRef ref,
    OccurrenceWithDetails o,
  ) async {
    final current = o.occurrence.amount ?? o.expense.amount;
    final controller = TextEditingController(text: current.toStringAsFixed(2));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit amount for ${o.expense.name}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      await ref.read(expenseOccurrencesDaoProvider).updateAmount(o.occurrence.id, result);
    }
  }
}

class _OccurrenceTile extends StatelessWidget {
  final OccurrenceWithDetails o;
  final String symbol;
  final VoidCallback onTogglePaid;
  final VoidCallback onToggleSkip;
  final VoidCallback onEditAmount;

  const _OccurrenceTile({
    required this.o,
    required this.symbol,
    required this.onTogglePaid,
    required this.onToggleSkip,
    required this.onEditAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = o.occurrence.isPaid;
    final isSkipped = o.occurrence.isSkipped;
    final muted = Theme.of(context).colorScheme.onSurface.withAlpha(100);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: isSkipped ? null : onTogglePaid,
      onLongPress: () => _showOptions(context),
      leading: CircleAvatar(
        backgroundColor: Color(o.category.color).withAlpha(isSkipped ? 30 : 50),
        child: Text(o.category.emoji),
      ),
      title: Text(
        o.expense.name,
        style: TextStyle(
          decoration: isPaid ? TextDecoration.lineThrough : null,
          color: (isPaid || isSkipped) ? muted : null,
        ),
      ),
      subtitle: Text(
        isSkipped ? 'Skipped' : o.category.name,
        style: TextStyle(color: isSkipped ? muted : null),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$symbol${(o.occurrence.amount ?? o.expense.amount).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: (isPaid || isSkipped) ? muted : null,
              decoration: isSkipped ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(width: 4),
          if (isSkipped)
            Icon(Icons.block, color: muted, size: 18)
          else if (isPaid)
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final isSkipped = o.occurrence.isSkipped;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(isSkipped ? Icons.replay : Icons.block),
              title: Text(isSkipped ? 'Un-skip' : 'Skip this occurrence'),
              onTap: () {
                Navigator.pop(context);
                onToggleSkip();
              },
            ),
            if (!isSkipped)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit amount'),
                onTap: () {
                  Navigator.pop(context);
                  onEditAmount();
                },
              ),
          ],
        ),
      ),
    );
  }
}
