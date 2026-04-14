import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';

class EditGlossaryEntryFeature {
  static void execute(BuildContext context, String entryId, String definition) {
    final repo = Provider.of<DocumentRepository>(context, listen: false);
    repo.updateGlossaryDefinition(entryId, definition);
  }
}