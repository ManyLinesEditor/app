import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/setting/setting_repository.dart';
import '../../../features/settings/toggle_setting_expansion.dart';
import '../../../features/settings/toggle_dark_mode.dart';
import '../../../shared/ui/buttons/primary_button.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final settingState = context.watch<SettingRepository>();
    final isDarkMode = settingState.isDarkMode;
    final bgColor = isDarkMode ? Colors.blue[900]! : Colors.blue[50]!;
    final borderColor = isDarkMode ? Colors.blue[700]! : Colors.blue[200]!;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    if (settingState.switchableValue) {
      return ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: settingState.settings.length,
        onReorder: (oldIndex, newIndex) => settingState.reorderSettings(oldIndex, newIndex),
        itemBuilder: (context, index) {
          final setting = settingState.settings[index];
          final isExpanded = setting.expanded;
          return Column(
            key: ValueKey(setting.id),
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingHeader(setting, isExpanded, textColor, borderColor, context),
              if (setting.id == 'setting1' && isExpanded) _buildDescriptionSection1(isDarkMode),
              if (setting.id == 'setting2' && isExpanded) _buildDescriptionSection2(isDarkMode, context),
              if (setting.id == 'setting3' && isExpanded) _buildDescriptionSection3(isDarkMode, context),
            ],
          );
        },
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: settingState.settings.length,
        itemBuilder: (context, index) {
          final setting = settingState.settings[index];
          final isExpanded = setting.expanded;
          return Column(
            key: ValueKey(setting.id),
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingHeader(setting, isExpanded, textColor, borderColor, context),
              if (setting.id == 'setting1' && isExpanded) _buildDescriptionSection1(isDarkMode),
              if (setting.id == 'setting2' && isExpanded) _buildDescriptionSection2(isDarkMode, context),
              if (setting.id == 'setting3' && isExpanded) _buildDescriptionSection3(isDarkMode, context),
            ],
          );
        },
      );
    }
  }

  Widget _buildSettingHeader(
    dynamic setting, bool isExpanded, Color textColor, Color borderColor, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
        color: context.watch<SettingRepository>().isDarkMode ? Colors.blue[800]! : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(setting.name, style: TextStyle(color: textColor)),
          Row(
            children: [
              IconButton(
                icon: Icon(isExpanded ? Icons.arrow_drop_down : Icons.arrow_drop_up, color: textColor),
                onPressed: () => ToggleSettingExpansionFeature.execute(context, setting.id),
              ),
              if (context.watch<SettingRepository>().switchableValue)
                Icon(Icons.drag_handle, 
                  color: context.watch<SettingRepository>().isDarkMode ? Colors.white54 : Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection1(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.grey[850]! : Colors.grey[50]!,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Description', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[300]! : Colors.grey[700]!)),
          const SizedBox(height: 12),
          Row(children: [
            _buildOutlinedButton('A', isDarkMode),
            const SizedBox(width: 8),
            _buildOutlinedButton('B', isDarkMode),
            const SizedBox(width: 8),
            _buildOutlinedButton('C', isDarkMode),
          ]),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection2(bool isDarkMode, BuildContext context) {
    return Container(
      color: isDarkMode ? Colors.grey[850]! : Colors.grey[50]!,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Description', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[300]! : Colors.grey[700]!)),
          const SizedBox(height: 12),
          Row(children: [
            _buildOutlinedButton('A', isDarkMode),
            const SizedBox(width: 8),
            _buildOutlinedButton('B', isDarkMode),
            const SizedBox(width: 8),
            _buildOutlinedButton('C', isDarkMode),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, 
                  size: 20, color: isDarkMode ? Colors.yellow[200]! : Colors.orange),
                const SizedBox(width: 8),
                Text(isDarkMode ? 'Тёмная тема' : 'Светлая тема', 
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              ]),
              Switch(
                value: isDarkMode,
                onChanged: (value) => ToggleDarkModeFeature.execute(context, value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection3(bool isDarkMode, BuildContext context) {
    return Container(
      color: isDarkMode ? Colors.grey[850]! : Colors.grey[50]!,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Description', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[300]! : Colors.grey[700]!)),  // ✅ Добавьте !
          const SizedBox(height: 12),
          Row(children: [
            _buildOutlinedButton('A', isDarkMode),
            const SizedBox(width: 8),
            _buildOutlinedButton('B', isDarkMode),
            const SizedBox(width: 8),
            _buildOutlinedButton('C', isDarkMode),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Switchable', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              Switch(
                value: context.watch<SettingRepository>().switchableValue,
                onChanged: (value) => context.read<SettingRepository>().setSwitchableValue(value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Listable', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              IconButton(
                icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.black87),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedButton(String label, bool isDarkMode) {
    return Expanded(
      child: PrimaryButton.outlined(
        onPressed: () {},
        label: label,
        isDarkMode: isDarkMode,
      ),
    );
  }
}