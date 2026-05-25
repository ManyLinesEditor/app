import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/project/project_repository.dart';
import '../../shared/ui/inputs/text_field.dart';

class CreateProjectFeature {
  static void show(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => Consumer<ProjectRepository>(
        builder: (context, repo, _) {
          return AlertDialog(
            title: const Text('Новый проект'),
            content: Form(
              key: formKey,
              child: CustomTextField(
                controller: controller,
                label: 'Название проекта',
                validator: (value) => 
                  value?.trim().isEmpty == true ? 'Введите название' : null,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    repo.addProject(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Создать'),
              ),
            ],
          );
        },
      ),
    );
  }
}