import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/setting/setting_repository.dart';

class ToggleDarkModeFeature {
  static void execute(BuildContext context, bool value) {
    final repo = Provider.of<SettingRepository>(context, listen: false);
    repo.toggleDarkMode(value);
  }
}