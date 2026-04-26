import 'package:flutter/foundation.dart';
import '../recurrence/frequency.dart';
import '../../data/database/app_database.dart';

class SettingsRepository extends ChangeNotifier {
  final AppSettingsDao _dao;

  bool? _onboardingComplete;
  String _currency = 'GBP';
  Frequency _defaultFrequency = Frequency.monthly;

  SettingsRepository(this._dao);

  bool? get onboardingComplete => _onboardingComplete;
  String get currency => _currency;
  Frequency get defaultFrequency => _defaultFrequency;

  Future<void> load() async {
    final flag = await _dao.getValue('onboarding_complete');
    _onboardingComplete = flag == 'true';
    _currency = await _dao.getValue('currency') ?? 'GBP';
    final freqStr = await _dao.getValue('default_frequency');
    _defaultFrequency = freqStr != null
        ? Frequency.values.byName(freqStr)
        : Frequency.monthly;
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
}
