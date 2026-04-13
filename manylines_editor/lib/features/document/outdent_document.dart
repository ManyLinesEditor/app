import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document_repository.dart';

class OutdentDocumentFeature {
  static void execute(BuildContext context, int index) {
    final repo = Provider.of<DocumentRepository>(context, listen: false);
    repo.outdentDocument(index);
  }
}