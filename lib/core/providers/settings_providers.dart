import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../settings/settings_repository.dart';
import 'database_providers.dart';

final settingsRepositoryProvider = ChangeNotifierProvider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appSettingsDaoProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
