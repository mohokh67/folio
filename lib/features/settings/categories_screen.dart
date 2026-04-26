import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/calendar_providers.dart';
import '../../core/providers/database_providers.dart';
import '../../data/database/app_database.dart';

const _kEmojis = [
  '🏠','🚗','🛒','🎬','💊','📱','🍽','📚','👕','💼','💰','🔧',
  '✈️','🏃','🐶','🎮','🎵','💅','🍺','☕','🏋','🎁','🏥','📦',
  '💻','📷','🌿','🏖','🎓','🚀','🔑','💡','🌍','🎯','🛠','🎪',
];

const _kColors = [
  0xFF5C6BC0, 0xFF42A5F5, 0xFF66BB6A, 0xFFAB47BC,
  0xFFEF5350, 0xFF26C6DA, 0xFFFF7043, 0xFF29B6F6,
  0xFFEC407A, 0xFF78909C, 0xFFFFCA28, 0xFF8D6E63,
  0xFF26A69A, 0xFF9CCC65, 0xFFFFA726, 0xFF7E57C2,
];

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cats) => ListView.builder(
          itemCount: cats.length,
          itemBuilder: (context, i) {
            final cat = cats[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(cat.color).withAlpha(50),
                child: Text(cat.emoji),
              ),
              title: Text(cat.name),
              subtitle: Text(cat.isCustom ? 'Custom' : 'Predefined'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showForm(context, ref, cat),
                  ),
                  if (cat.isCustom)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _confirmDelete(context, ref, cat),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showForm(BuildContext context, WidgetRef ref, Category? existing) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CategoryForm(existing: existing),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Category cat) async {
    final expensesDao = ref.read(expensesDaoProvider);
    final occurrencesDao = ref.read(expenseOccurrencesDaoProvider);
    final categoriesDao = ref.read(categoriesDaoProvider);

    final expenses = await expensesDao.getExpensesByCategory(cat.id);

    if (!context.mounted) return;

    if (expenses.isEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete category?'),
          content: Text('Delete "${cat.name}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
          ],
        ),
      );
      if (confirmed == true) await categoriesDao.deleteCategory(cat.id);
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete category?'),
          content: Text(
            '"${cat.name}" is used by ${expenses.length} expense(s). '
            'Deleting it will also delete those expenses and all their payment history.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete all'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        for (final e in expenses) {
          await occurrencesDao.deleteOccurrencesByExpense(e.id);
          await expensesDao.deleteExpense(e.id);
        }
        await categoriesDao.deleteCategory(cat.id);
      }
    }
  }
}

class _CategoryForm extends ConsumerStatefulWidget {
  final Category? existing;
  const _CategoryForm({this.existing});

  @override
  ConsumerState<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<_CategoryForm> {
  late final TextEditingController _nameCtrl;
  late String _emoji;
  late int _color;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _emoji = widget.existing?.emoji ?? _kEmojis.first;
    _color = widget.existing?.color ?? _kColors.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isEdit ? 'Edit category' : 'New category',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Icon', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: _kEmojis.length,
              itemBuilder: (context, i) {
                final e = _kEmojis[i];
                final selected = e == _emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: selected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 22)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text('Color', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kColors.map((c) {
              final selected = c == _color;
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Text(isEdit ? 'Save' : 'Add category'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(categoriesDaoProvider);

    if (widget.existing != null) {
      await dao.updateCategory(CategoriesCompanion(
        id: Value(widget.existing!.id),
        name: Value(name),
        emoji: Value(_emoji),
        color: Value(_color),
        isCustom: Value(widget.existing!.isCustom),
      ));
    } else {
      await dao.insertCategory(CategoriesCompanion.insert(
        name: name,
        emoji: _emoji,
        color: _color,
        isCustom: const Value(true),
      ));
    }

    if (mounted) Navigator.pop(context);
  }
}
