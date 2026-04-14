import 'package:flutter/foundation.dart';
import 'setting.dart';

class SettingRepository extends ChangeNotifier {
  final List<Setting> _settings = [
    Setting(id: 'setting1', name: 'Setting 1', expanded: true),
    Setting(id: 'setting2', name: 'Setting 2', expanded: false),
    Setting(id: 'setting3', name: 'Setting 3', expanded: true),
  ];

  bool _switchableValue = true;
  bool _isDarkMode = false;
  bool _isGraphView = false;
  bool _isSidePanelCollapsed = false;

  List<Setting> get settings => _settings;
  bool get switchableValue => _switchableValue;
  bool get isDarkMode => _isDarkMode;
  bool get isGraphView => _isGraphView;
  bool get isSidePanelCollapsed => _isSidePanelCollapsed;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleViewMode() {
    _isGraphView = !_isGraphView;
    notifyListeners();
  }

  void toggleSidePanel() {
    _isSidePanelCollapsed = !_isSidePanelCollapsed;
    notifyListeners();
  }

  void setSwitchableValue(bool value) {
    _switchableValue = value;
    notifyListeners();
  }

  void reorderSettings(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _settings.removeAt(oldIndex);
    _settings.insert(newIndex, item);
    notifyListeners();
  }

  void toggleSettingExpansion(String id) {
    for (var setting in _settings) {
      if (setting.id == id) {
        setting.expanded = !setting.expanded;
        notifyListeners();
        break;
      }
    }
  }

  void toggleSettingEnabled(String id, bool value) {
    for (var setting in _settings) {
      if (setting.id == id) {
        setting.enabled = value;
        notifyListeners();
        break;
      }
    }
  }
}