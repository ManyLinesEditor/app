import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/project/project_repository.dart';
import '../../../entities/setting/setting_repository.dart';

class ProjectHeader extends StatelessWidget {
  const ProjectHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final settingState = context.watch<SettingRepository>();
    
    final isDarkMode = settingState.isDarkMode;
    final headerBg = isDarkMode ? Colors.grey[850] : Colors.white;
    final logoBg = isDarkMode ? Colors.grey[800] : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final logoBorderColor = isDarkMode ? Colors.grey[600]! : Colors.grey[400]!;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final logoTextColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
        color: headerBg,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: logoBorderColor),
              color: logoBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('Logo', style: TextStyle(fontWeight: FontWeight.bold, color: logoTextColor)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Manyllines', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor))),
        ],
      ),
    );
  }
}