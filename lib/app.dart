import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/settings_providers.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    ref.read(settingsRepositoryProvider).load();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsRepositoryProvider);
    return MaterialApp.router(
      title: 'Folio',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
