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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectRepository()),
        ChangeNotifierProvider(create: (_) => DocumentRepository()),
        ChangeNotifierProvider(create: (_) => SettingRepository()),
      ],
      child: child,
    );
  }
}