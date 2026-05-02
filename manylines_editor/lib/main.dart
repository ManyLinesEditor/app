import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/providers.dart';
import 'app/theme.dart';
import 'app/router.dart';
import 'entities/setting/setting_repository.dart';

void main() {
  runApp(const ManylinesApp());
}

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