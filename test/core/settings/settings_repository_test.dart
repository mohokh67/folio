import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/recurrence/frequency.dart';
import 'package:folio/core/settings/settings_repository.dart';
import 'package:folio/data/database/app_database.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SettingsRepository(db.appSettingsDao);
  });

  tearDown(() => db.close());

  test('defaults before load', () {
    expect(repo.onboardingComplete, isNull);
    expect(repo.currency, 'GBP');
    expect(repo.defaultFrequency, Frequency.monthly);
  });

  test('load with empty DB → onboardingComplete false, defaults kept', () async {
    await repo.load();
    expect(repo.onboardingComplete, false);
    expect(repo.currency, 'GBP');
    expect(repo.defaultFrequency, Frequency.monthly);
  });

  test('completeOnboarding saves values and sets flag', () async {
    await repo.load();
    await repo.completeOnboarding(currency: 'USD', defaultFrequency: Frequency.weekly);
    expect(repo.onboardingComplete, true);
    expect(repo.currency, 'USD');
    expect(repo.defaultFrequency, Frequency.weekly);
  });

  test('load after completeOnboarding reads persisted values', () async {
    await repo.load();
    await repo.completeOnboarding(currency: 'EUR', defaultFrequency: Frequency.annually);
    final repo2 = SettingsRepository(db.appSettingsDao);
    await repo2.load();
    expect(repo2.onboardingComplete, true);
    expect(repo2.currency, 'EUR');
    expect(repo2.defaultFrequency, Frequency.annually);
  });

  test('completeOnboarding notifies listeners', () async {
    await repo.load();
    var notified = false;
    repo.addListener(() => notified = true);
    await repo.completeOnboarding(currency: 'GBP', defaultFrequency: Frequency.monthly);
    expect(notified, true);
  });
}
