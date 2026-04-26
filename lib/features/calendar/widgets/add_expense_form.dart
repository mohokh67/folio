import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/calendar_providers.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/recurrence/frequency.dart';
import '../../../data/database/app_database.dart';

const _monthAbbr = [
  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmtDate(DateTime d) => '${d.day} ${_monthAbbr[d.month]} ${d.year}';

class AddExpenseForm extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const AddExpenseForm({super.key, required this.initialDate});

  @override
  ConsumerState<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends ConsumerState<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late DateTime _startDate;
  DateTime? _endDate;
  Frequency? _frequency;
  int? _categoryId;
  bool _alreadyPaid = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDate;
    _frequency = ref.read(settingsRepositoryProvider).defaultFrequency;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isEnd}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEnd ? (_endDate ?? _startDate) : _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => isEnd ? _endDate = picked : _startDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }
    setState(() => _saving = true);

    final expensesDao = ref.read(expensesDaoProvider);
    final occurrencesDao = ref.read(expenseOccurrencesDaoProvider);
    final generator = ref.read(occurrenceGeneratorProvider);

    final expenseId = await expensesDao.insertExpense(ExpensesCompanion.insert(
      categoryId: _categoryId!,
      name: _nameCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text),
      startDate: Value(_startDate),
      endDate: Value(_endDate),
      frequency: Value(_frequency?.name),
    ));

    if (_frequency == null) {
      await occurrencesDao.insertOccurrence(ExpenseOccurrencesCompanion.insert(
        expenseId: expenseId,
        date: _startDate,
        note: Value(_notesCtrl.text.isEmpty ? null : _notesCtrl.text),
        isPaid: Value(_alreadyPaid),
      ));
    } else {
      for (var offset = -1; offset <= 1; offset++) {
        await generator.generateForMonth(
          DateTime(_startDate.year, _startDate.month + offset, 1),
        );
      }
      if (_alreadyPaid || _notesCtrl.text.isNotEmpty) {
        final occs = await occurrencesDao.getOccurrencesByExpenseAndDateRange(
          expenseId, _startDate, _startDate,
        );
        if (occs.isNotEmpty) {
          await occurrencesDao.updateOccurrence(ExpenseOccurrencesCompanion(
            id: Value(occs.first.id),
            expenseId: Value(occs.first.expenseId),
            date: Value(occs.first.date),
            amount: Value(occs.first.amount),
            isPaid: Value(_alreadyPaid),
            note: Value(_notesCtrl.text.isEmpty ? null : _notesCtrl.text),
          ));
        }
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add expense',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (cats) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _categoryId,
                  items: cats
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.emoji} ${c.name}'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Frequency?>(
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                value: _frequency,
                items: [
                  const DropdownMenuItem<Frequency?>(
                    value: null,
                    child: Text('One-off'),
                  ),
                  ...Frequency.values.map(
                    (f) => DropdownMenuItem(value: f, child: Text(f.label)),
                  ),
                ],
                onChanged: (v) => setState(() => _frequency = v),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text('Start: ${_fmtDate(_startDate)}'),
                onPressed: () => _pickDate(isEnd: false),
              ),
              if (_frequency != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.event, size: 16),
                  label: Text(_endDate == null
                      ? 'End date (optional)'
                      : 'End: ${_fmtDate(_endDate!)}'),
                  onPressed: () => _pickDate(isEnd: true),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Already paid'),
                value: _alreadyPaid,
                onChanged: (v) => setState(() => _alreadyPaid = v),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
