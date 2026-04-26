import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'reminders';
  static const _channelName = 'Expense Reminders';

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
    );
  }

  Future<void> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  Future<void> scheduleForOccurrence({
    required int occurrenceId,
    required String expenseName,
    required double amount,
    required String currency,
    required DateTime dueDate,
    required int reminderDays,
  }) async {
    final reminderDate = dueDate.subtract(Duration(days: reminderDays));
    final scheduleAt = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
      0,
    );
    if (scheduleAt.isBefore(DateTime.now())) return;

    final tzSchedule = tz.TZDateTime.from(scheduleAt, tz.local);
    final dueLabel = reminderDays == 0
        ? 'today'
        : reminderDays == 1
            ? 'tomorrow'
            : 'in $reminderDays days';

    await _plugin.zonedSchedule(
      occurrenceId,
      'Upcoming: $expenseName',
      '$currency ${amount.toStringAsFixed(2)} due $dueLabel',
      tzSchedule,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelForOccurrence(int occurrenceId) async {
    await _plugin.cancel(occurrenceId);
  }
}
