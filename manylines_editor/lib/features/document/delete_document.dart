import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document.dart';
import '../../entities/document/document_repository.dart';
import '../../entities/project/project_repository.dart';
import '../../entities/setting/setting_repository.dart';

class DeleteDocumentFeature {
  static void showConfirmation(BuildContext context, AppDocument doc) {
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        title: const Text('Удалить документ?'),
        content: Text('Документ "${doc.name}" будет удалён без возможности восстановления.', 
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              execute(context, doc);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  static void execute(BuildContext context, AppDocument doc) {
    final projectRepo = Provider.of<ProjectRepository>(context, listen: false);
    final documentRepo = Provider.of<DocumentRepository>(context, listen: false);
    
    projectRepo.deleteDocument(doc);
    documentRepo.closeEditorIfOpen(doc.id);
  }
}