import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_repository.dart';
import 'database_providers.dart';

final settingsRepositoryProvider = ChangeNotifierProvider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appSettingsDaoProvider));
});
