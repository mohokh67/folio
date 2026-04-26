import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/calendar_providers.dart';
import '../../core/providers/settings_providers.dart';
import '../../data/database/app_database.dart';
import 'widgets/add_expense_form.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/day_sheet.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

// PageView ↔ month: Jan 2020 = page 0
final _refDate = DateTime(2020, 1, 1);

int _monthToPage(DateTime m) =>
    (m.year - _refDate.year) * 12 + (m.month - _refDate.month);

DateTime _pageToMonth(int p) => DateTime(_refDate.year, _refDate.month + p, 1);

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final month = ref.read(currentMonthProvider);
    _pageController = PageController(initialPage: _monthToPage(month));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(DateTime month) {
    _pageController.animateToPage(
      _monthToPage(month),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Map<DateTime, List<Color>> _buildDots(List<OccurrenceWithDetails> data) {
    final map = <DateTime, List<Color>>{};
    for (final o in data) {
      final d = o.occurrence.date;
      final day = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(day, () => []).add(Color(o.category.color));
    }
    return map;
  }

  void _showDaySheet(BuildContext context, DateTime date, List<OccurrenceWithDetails> all) {
    final dayData = all.where((o) {
      final d = o.occurrence.date;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();

    final currency = ref.read(settingsRepositoryProvider).currency;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DaySheet(
        date: date,
        occurrences: dayData,
        currency: currency,
        onAdd: () {
          Navigator.pop(context);
          _showAddForm(context, date);
        },
      ),
    );
  }

  void _showAddForm(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExpenseForm(initialDate: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = ref.watch(currentMonthProvider);
    final calendarAsync = ref.watch(calendarDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_monthNames[currentMonth.month - 1]} ${currentMonth.year}'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _goTo(DateTime(currentMonth.year, currentMonth.month - 1)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _goTo(DateTime(currentMonth.year, currentMonth.month + 1)),
          ),
        ],
      ),
      body: calendarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (occurrences) {
          final dots = _buildDots(occurrences);
          return PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              ref.read(currentMonthProvider.notifier).state = _pageToMonth(page);
            },
            itemBuilder: (context, page) {
              final month = _pageToMonth(page);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: CalendarGrid(
                  month: month,
                  dotsByDay: dots,
                  onDayTap: (date) => _showDaySheet(context, date, occurrences),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
