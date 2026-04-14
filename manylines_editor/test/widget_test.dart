import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:manylines_editor/main.dart';
import 'package:manylines_editor/app/providers.dart';
import 'package:manylines_editor/entities/setting/setting_repository.dart';
import 'package:manylines_editor/entities/project/project_repository.dart';

void main() {

  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ManyllinesApp());
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    
    expect(find.text('Manylines'), findsOneWidget);
  });

  testWidgets('Can create a new project', (WidgetTester tester) async {
    await tester.pumpWidget(const ManyllinesApp());
    await tester.pumpAndSettle();

    final fabFinder = find.byWidgetPredicate(
      (widget) => widget is FloatingActionButton && widget.tooltip == 'Новый документ',
    );
    
    if (fabFinder.evaluate().isEmpty) {
      await tester.tap(find.byIcon(Icons.add));
    } else {
      await tester.tap(fabFinder);
    }
    await tester.pumpAndSettle();

    expect(find.text('Новый документ'), findsOneWidget);
    
    await tester.enterText(find.byType(TextFormField), 'Test Project');
    await tester.pump();
    
    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();
    
    expect(find.text('Test Project'), findsOneWidget);
  });

  testWidgets('Can toggle dark mode', (WidgetTester tester) async {
    await tester.pumpWidget(const ManyllinesApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ManyllinesApp).first);
    final settingRepo = Provider.of<SettingRepository>(context, listen: false);
    
    settingRepo.toggleDarkMode(true);
    await tester.pump();
    
    expect(settingRepo.isDarkMode, isTrue);
  });

  testWidgets('Can select a project', (WidgetTester tester) async {
    await tester.pumpWidget(const ManyllinesApp());
    await tester.pumpAndSettle();

    final projectTile = find.text('Project 1');
    expect(projectTile, findsOneWidget);
    
    await tester.tap(projectTile);
    await tester.pumpAndSettle();
    
    expect(find.byType(AnimatedContainer), findsOneWidget);
  });
}