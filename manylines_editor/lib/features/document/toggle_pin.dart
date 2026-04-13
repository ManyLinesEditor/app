import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document.dart';
import '../../entities/document/document_repository.dart';

class TogglePinFeature {
  static void execute(BuildContext context, AppDocument doc) {
    final repo = Provider.of<DocumentRepository>(context, listen: false);
    repo.togglePin(doc);
  }
}