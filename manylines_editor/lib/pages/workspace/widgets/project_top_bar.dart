import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/project/project_repository.dart';
import '../../../entities/setting/setting_repository.dart';

class ProjectTopBar extends StatelessWidget {
  const ProjectTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final settingState = context.watch<SettingRepository>();
    final isDarkMode = settingState.isDarkMode;
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF603D2E)
            : const Color(0xFFFFEDEB),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode 
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color(0xFF603D2E),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset(
              isDarkMode 
                  ? 'assets/images/logo_dark.png' 
                  : 'assets/images/logo_light.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
          ),
          
          Expanded(
            child: Center(
              child: Text(
                projectState.selectedProject?.name ?? 'Project',
                style: TextStyle(
                  fontFamily: 'Ostrovsky',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode 
                      ? Colors.white 
                      : const Color(0xFF603D2E),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    settingState.isSidePanelCollapsed 
                        ? Icons.menu 
                        : Icons.close,
                    color: isDarkMode 
                        ? Colors.white 
                        : const Color(0xFF603D2E),
                  ),
                  onPressed: () => settingState.toggleSidePanel(),
                  tooltip: 'Панель',
                ),
                IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: isDarkMode 
                        ? Colors.white 
                        : const Color(0xFF603D2E),
                  ),
                  onPressed: () => settingState.toggleDarkMode(!isDarkMode),
                  tooltip: isDarkMode ? 'Светлая' : 'Тёмная',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}