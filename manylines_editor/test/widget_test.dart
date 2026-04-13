// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:manylines_editor/main.dart';

void main() {
  // ✅ Простой тест: приложение загружается без крашей
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Запускаем упрощённый TestApp вместо MyApp
    await tester.pumpWidget(const TestApp());
    
    // Даём время на отрисовку всех виджетов
    await tester.pumpAndSettle();

    // ✅ Проверка 1: приложение содержит Scaffold
    expect(find.byType(Scaffold), findsOneWidget);
    
    // ✅ Проверка 2: заголовок приложения отрисовался
    expect(find.text('Manyllines'), findsOneWidget);
    
    // ✅ Проверка 3: экран проектов загрузился (ищем текст из ProjectsScreen)
    expect(find.text('Logo'), findsOneWidget);
  });

  // ✅ Тест: создание проекта работает
  testWidgets('Can create a new project', (WidgetTester tester) async {
    await tester.pumpWidget(const TestApp());
    await tester.pumpAndSettle();

    // Находим и нажимаем FAB для создания проекта
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);
    
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // Проверяем, что диалог создания проекта открылся
    expect(find.text('Новый проект'), findsOneWidget);
    
    // Вводим название проекта
    await tester.enterText(find.byType(TextFormField), 'Test Project');
    await tester.pump();
    
    // Нажимаем "Создать"
    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();
    
    // Проверяем, что проект появился в списке
    expect(find.text('Test Project'), findsOneWidget);
  });

  // ✅ Тест: переключение темы работает (исправленная версия)
  testWidgets('Can toggle dark mode', (WidgetTester tester) async {
    await tester.pumpWidget(const TestApp());
    await tester.pumpAndSettle();

    // ✅ Правильный способ получить AppState в тесте:
    // Используем Provider.of через контекст виджета
    final context = tester.element(find.byType(AppShell).first);
    final state = Provider.of<AppState>(context, listen: false);
    
    // Меняем тему
    state.toggleDarkMode(true);
    await tester.pump();
    
    // Проверяем, что тема изменилась (проверяем, что состояние обновилось)
    expect(state.isDarkMode, isTrue);
  });

  // ✅ Тест: выбор проекта работает
  testWidgets('Can select a project', (WidgetTester tester) async {
    await tester.pumpWidget(const TestApp());
    await tester.pumpAndSettle();

    // Находим первый проект в списке
    final projectTile = find.text('Project 1');
    expect(projectTile, findsOneWidget);
    
    // Нажимаем на проект
    await tester.tap(projectTile);
    await tester.pumpAndSettle();
    
    // Проверяем, что открылось рабочее пространство
    expect(find.byType(ProjectWorkspace), findsOneWidget);
  });
}