import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/project/project_repository.dart';

class ToggleGlossaryEntryFeature {
  static void execute(
    BuildContext context, 
    String entryId,
  ) {
    final repo = Provider.of<ProjectRepository>(context, listen: false);
    
    repo.toggleGlossaryEntry(entryId);
  }
}