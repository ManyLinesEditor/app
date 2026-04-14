import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import '../../entities/document/document_repository.dart';
import '../../entities/project/project_repository.dart';
import '../../entities/setting/setting_repository.dart';
import '../../shared/ui/inputs/text_field.dart';

class CreateDocumentFeature {
  static void show(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = context.watch<SettingRepository>().isDarkMode;
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          title: Text('Новый документ', 
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
          content: Form(
            key: formKey,
            child: CustomTextField(
              controller: controller,
              label: 'Название документа',
              prefixIcon: Icons.description,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Введите название документа';
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState!.validate()) {
                  execute(context, controller.text.trim());
                  Navigator.pop(context);
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  execute(context, controller.text.trim());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Создать'),
            ),
          ],
        );
      },
    );
  }

  static void execute(BuildContext context, String name) {
    final projectRepo = Provider.of<ProjectRepository>(context, listen: false);
    final documentRepo = Provider.of<DocumentRepository>(context, listen: false);
    
    if (projectRepo.selectedProject == null) return;
    
    final newDoc = documentRepo.createDocument(
      name: name,
      content: Delta()..insert('New document content...\n'),
    );
    
    projectRepo.addDocumentToProject(newDoc);
    
    documentRepo.selectDocument(newDoc);
  }
}