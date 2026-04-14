import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/project/project_repository.dart';
import '../../../entities/setting/setting_repository.dart';
import '../../../shared/ui/inputs/text_field.dart';

class ProjectDialog {
  static void showCreate(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => Consumer<ProjectRepository>(
        builder: (context, repo, _) {
          final isDarkMode = context.watch<SettingRepository>().isDarkMode;
          return AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
            title: Text('Новый проект', 
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            content: Form(
              key: formKey,
              child: CustomTextField(
                controller: controller,
                label: 'Название проекта',
                prefixIcon: Icons.folder,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Введите название проекта';
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (formKey.currentState!.validate()) {
                    repo.addProject(controller.text.trim());
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
                    repo.addProject(controller.text.trim());
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
      ),
    );
  }
}