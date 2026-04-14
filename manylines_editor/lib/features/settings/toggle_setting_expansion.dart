import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/setting/setting_repository.dart';

class ToggleSettingExpansionFeature {
  static void execute(BuildContext context, String id) {
    final repo = Provider.of<SettingRepository>(context, listen: false);
    repo.toggleSettingExpansion(id);
  }
}