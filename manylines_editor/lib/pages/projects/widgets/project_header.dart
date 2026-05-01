// lib/pages/projects/widgets/project_header.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/setting/setting_repository.dart';

class ProjectHeader extends StatelessWidget {
  const ProjectHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final settingState = context.watch<SettingRepository>();
    final isDarkMode = settingState.isDarkMode;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color.fromARGB(255, 29, 10, 1) : const Color(0xFFFFEDEB),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? const Color(0xFF16DB93) : Color(0xFFAB73D3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          // ✅ Логотип PNG
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
          const SizedBox(width: 12),
          
          // ✅ Название приложения
          Text(
            'Manylines',
            style: TextStyle(
              fontFamily: 'LT Remark',  // ✅ Шрифт заголовков
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode 
                  ? Colors.white 
                  : const Color(0xFF603D2E),  // ✅ Коричневый
            ),
          ),
        ],
      ),
    );
  }
}