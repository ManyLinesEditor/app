import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/project/project_repository.dart';

class ToggleViewModeFeature {
  static void execute(BuildContext context) {
    final repo = Provider.of<ProjectRepository>(context, listen: false);
    repo.toggleViewMode();
  }
}