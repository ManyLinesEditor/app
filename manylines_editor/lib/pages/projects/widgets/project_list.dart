import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/project/project_repository.dart';
import '../../../entities/setting/setting_repository.dart';
import '../../../features/project/select_project.dart';

class ProjectList extends StatelessWidget {
  const ProjectList({super.key});

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final settingState = context.watch<SettingRepository>();
    
    final bgColor = settingState.isDarkMode ? Colors.green[900] : Colors.green[50];
    final borderColor = settingState.isDarkMode 
        ? const Color.fromARGB(255, 0, 47, 22) 
        : Colors.green.shade200;
    final textColor = settingState.isDarkMode ? Colors.white : Colors.black87;

    if (settingState.switchableValue) {
      return ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: projectState.projects.length,
        onReorder: (oldIndex, newIndex) => projectState.reorderProjects(oldIndex, newIndex),
        itemBuilder: (context, index) {
          final project = projectState.projects[index];
          return Container(
            key: ValueKey(project.id),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: ListTile(
              title: Text(project.name, style: TextStyle(color: textColor)),
              subtitle: Text('${project.documents.length} документов', 
                style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
              trailing: Icon(Icons.drag_handle, 
                color: settingState.isDarkMode ? Colors.white54 : Colors.grey),
              onTap: () => SelectProjectFeature.execute(context, project),
            ),
          );
        },
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projectState.projects.length,
          itemBuilder: (context, index) {
            final project = projectState.projects[index];
            return Container(
              key: ValueKey(project.id),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: ListTile(
                title: Text(project.name, style: TextStyle(color: textColor)),
                subtitle: Text('${project.documents.length} документов', 
                  style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
                onTap: () => SelectProjectFeature.execute(context, project),
              ),
            );
          },
        ),
      );
    }
  }
}