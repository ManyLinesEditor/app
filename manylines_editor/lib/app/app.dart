import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'theme.dart';
import 'router.dart';
import '../entities/setting/setting_repository.dart';

class ManylinesApp extends StatelessWidget {
  const ManylinesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: Consumer<SettingRepository>(
        builder: (context, settingState, _) {
          return MaterialApp(
            title: 'Manylines',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settingState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: AppLocalizations.delegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ru', 'RU'),
            home: const AppRouter(),
          );
        },
      ),
    );
  }
}