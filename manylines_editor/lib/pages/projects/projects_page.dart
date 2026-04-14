import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/project/project_repository.dart';
import '../../entities/setting/setting_repository.dart';
import '../../shared/ui/layouts/constrained_layout.dart';
import '../../features/project/create_project.dart';
import 'widgets/project_header.dart';
import 'widgets/project_list.dart';
import 'widgets/settings_list.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedLayout(
        child: Column(
          children: [
            const ProjectHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const ProjectList(),
                    const SettingsList(),
                    _buildOtherSettings(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateProjectFeature.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOtherSettings(BuildContext context) {
    final state = context.watch<SettingRepository>();
    final isDarkMode = state.isDarkMode;
    final textColor = isDarkMode ? Colors.white54 : Colors.black54;
    final bgColor = isDarkMode 
        ? const Color.fromARGB(255, 6, 58, 137) 
        : Colors.blue[50];
    
    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text('Other Settings ...', style: TextStyle(color: textColor)),
      ),
    );
  }
}