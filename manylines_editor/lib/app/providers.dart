import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entities/project/project_repository.dart';
import '../entities/document/document_repository.dart';
import '../entities/setting/setting_repository.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {

    final projectRepo = ProjectRepository();
    final documentRepo = DocumentRepository(projectRepo);
    final settingRepo = SettingRepository();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: projectRepo),
        ChangeNotifierProvider.value(value: documentRepo),
        ChangeNotifierProvider.value(value: settingRepo),
      ],
      child: child,
    );
  }
}