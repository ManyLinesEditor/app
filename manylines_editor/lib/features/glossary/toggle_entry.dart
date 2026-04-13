import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';

class ToggleGlossaryEntryFeature {
  static void execute(BuildContext context, String entryId) {
    final repo = Provider.of<DocumentRepository>(context, listen: false);
    repo.toggleGlossaryEntry(entryId);
  }
}