import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entities/project/project.dart';
import '../pages/projects/projects_page.dart';
import '../pages/workspace/workspace_page.dart';
import '../entities/project/project_repository.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ProjectRepository, Project?>(
      selector: (_, repo) => repo.selectedProject,
      builder: (context, selectedProject, _) {
        return selectedProject == null 
            ? const ProjectsPage() 
            : const WorkspacePage();
      },
    );
  }
}