import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/database_providers.dart';
import '../../core/providers/settings_providers.dart';
import '../../core/recurrence/frequency.dart';
import '../../core/services/csv_export_service.dart';
import 'categories_screen.dart';

const _currencies = ['GBP', 'USD', 'EUR', 'CAD', 'AUD', 'JPY', 'CHF', 'INR', 'SGD', 'NZD'];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader('Preferences'),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            trailing: DropdownButton<String>(
              value: settings.currency,
              underline: const SizedBox.shrink(),
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) ref.read(settingsRepositoryProvider).setCurrency(v);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Default frequency'),
            trailing: DropdownButton<Frequency>(
              value: settings.defaultFrequency,
              underline: const SizedBox.shrink(),
              items: Frequency.values
                  .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) ref.read(settingsRepositoryProvider).setDefaultFrequency(v);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_week),
            title: const Text('Week starts on'),
            trailing: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Mon')),
                ButtonSegment(value: true, label: Text('Sun')),
              ],
              selected: {settings.weekStartSunday},
              onSelectionChanged: (v) =>
                  ref.read(settingsRepositoryProvider).setWeekStartSunday(v.first),
              showSelectedIcon: false,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (v) {
                if (v != null) ref.read(settingsRepositoryProvider).setThemeMode(v);
              },
            ),
          ),
          const Divider(),
          _SectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            subtitle: const Text('Add, edit, or remove categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export CSV'),
            subtitle: const Text('Share all expenses as a CSV file'),
            onTap: () async {
              final dao = ref.read(expenseOccurrencesDaoProvider);
              final currency = ref.read(settingsRepositoryProvider).currency;
              try {
                await CsvExportService().export(dao, currency);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
