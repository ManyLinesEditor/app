import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_localizations/flutter_localizations.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF16DB93),
    brightness: Brightness.light,
    fontFamily: 'LT Remark',
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFFAB73D3),
    brightness: Brightness.dark,
    fontFamily: 'LT Remark',
  );
}

class AppLocalizations {
  static const delegates = [
    quill.FlutterQuillLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const supportedLocales = [
    Locale('ru', 'RU'),
    Locale('en', 'US'),
  ];
}