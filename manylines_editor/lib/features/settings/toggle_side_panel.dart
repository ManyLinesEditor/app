import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/setting/setting_repository.dart';

class ToggleSidePanelFeature {
  static void execute(BuildContext context) {
    final repo = Provider.of<SettingRepository>(context, listen: false);
    repo.toggleSidePanel();
  }
}