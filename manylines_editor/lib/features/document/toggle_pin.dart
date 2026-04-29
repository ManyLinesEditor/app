import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document.dart';
import '../../entities/document/document_repository.dart';
import '../../entities/project/project_repository.dart';


class TogglePinFeature {
  static void execute(BuildContext context, AppDocument doc) {
    final documentRepo = Provider.of<DocumentRepository>(context, listen: false);
    final projectRepo = Provider.of<ProjectRepository>(context, listen: false);
    
    // ✅ Переключаем pin
    documentRepo.togglePin(doc);
    
    // ✅ Уведомляем ProjectRepository для обновления UI списка
    projectRepo.notifyListeners();
  }
}