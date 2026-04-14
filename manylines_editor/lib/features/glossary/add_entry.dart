import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';
import '../../entities/glossary_entry/glossary_entry.dart';

class AddGlossaryEntryFeature {
  static void execute(
    BuildContext context, 
    String term, 
    String documentId,
  ) {
    final repo = Provider.of<DocumentRepository>(context, listen: false);
    
    final newEntry = GlossaryEntry(
      id: 'g${DateTime.now().millisecondsSinceEpoch}',
      term: term,
      definition: '',
      isExpanded: true,
    );
    
    repo.addGlossaryEntry(documentId, term);
  }
}