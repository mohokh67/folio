import 'package:flutter/material.dart';

const _weekdaysMon = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdaysSun = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, List<Color>> dotsByDay;
  final void Function(DateTime date) onDayTap;
  final bool startOnSunday;

  const CalendarGrid({
    super.key,
    required this.month,
    required this.dotsByDay,
    required this.onDayTap,
    this.startOnSunday = false,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Mon start: Mon=1→0, ..., Sun=7→6
    // Sun start: Sun=7→0, Mon=1→1, ..., Sat=6→6
    final leadingEmpties = startOnSunday
        ? firstDay.weekday % 7
        : firstDay.weekday - 1;
    final weekdays = startOnSunday ? _weekdaysSun : _weekdaysMon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: weekdays
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 52,
          ),
          itemCount: leadingEmpties + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leadingEmpties) return const SizedBox.shrink();
            final day = index - leadingEmpties + 1;
            final date = DateTime(month.year, month.month, day);
            final dots = dotsByDay[date] ?? [];
            final isToday = _isSameDay(date, DateTime.now());
            return GestureDetector(
              onTap: () => onDayTap(date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: isToday
                    ? BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (dots.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dots.take(4).map((c) => Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: c,
                                ),
                              )).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
