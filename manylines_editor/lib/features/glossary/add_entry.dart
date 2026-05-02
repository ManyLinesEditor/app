import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/project/project_repository.dart';

class AddGlossaryEntryFeature {
  static void execute(
    BuildContext context, 
    String term, 
    String definition,
  ) {
    final repo = Provider.of<ProjectRepository>(context, listen: false);
    
    repo.addGlossaryEntry(term, definition);
  }
}