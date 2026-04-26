import 'package:flutter/material.dart';
import '../recurrence/frequency.dart';
import '../../data/database/app_database.dart';

class SettingsRepository extends ChangeNotifier {
  final AppSettingsDao _dao;

  bool? _onboardingComplete;
  String _currency = 'GBP';
  Frequency _defaultFrequency = Frequency.monthly;
  bool _weekStartSunday = false;
  ThemeMode _themeMode = ThemeMode.system;

  SettingsRepository(this._dao);

  bool? get onboardingComplete => _onboardingComplete;
  String get currency => _currency;
  Frequency get defaultFrequency => _defaultFrequency;
  bool get weekStartSunday => _weekStartSunday;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final flag = await _dao.getValue('onboarding_complete');
    _onboardingComplete = flag == 'true';
    _currency = await _dao.getValue('currency') ?? 'GBP';
    final freqStr = await _dao.getValue('default_frequency');
    _defaultFrequency = freqStr != null
        ? Frequency.values.byName(freqStr)
        : Frequency.monthly;
    _weekStartSunday = (await _dao.getValue('week_start_sunday')) == 'true';
    final themeStr = await _dao.getValue('theme_mode');
    _themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String currency,
    required Frequency defaultFrequency,
  }) async {
    await _dao.setValue('currency', currency);
    await _dao.setValue('default_frequency', defaultFrequency.name);
    await _dao.setValue('onboarding_complete', 'true');
    _onboardingComplete = true;
    _currency = currency;
    _defaultFrequency = defaultFrequency;
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    await _dao.setValue('currency', currency);
    _currency = currency;
    notifyListeners();
  }

  Future<void> setDefaultFrequency(Frequency frequency) async {
    await _dao.setValue('default_frequency', frequency.name);
    _defaultFrequency = frequency;
    notifyListeners();
  }

  Future<void> setWeekStartSunday(bool sunday) async {
    await _dao.setValue('week_start_sunday', sunday.toString());
    _weekStartSunday = sunday;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _dao.setValue('theme_mode', str);
    _themeMode = mode;
    notifyListeners();
  }
}
