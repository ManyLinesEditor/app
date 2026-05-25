import 'package:flutter/material.dart';

class Helpers {
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static Color getBorderColor(bool isDarkMode, {bool isPinned = false}) {
    if (isDarkMode) {
      return isPinned ? Colors.green[700]! : Colors.blue[700]!;
    }
    return isPinned ? Colors.green[200]! : Colors.blue[200]!;
  }

  static Color getBackgroundColor(bool isDarkMode, {bool isPinned = false}) {
    if (isDarkMode) {
      return isPinned 
          ? Colors.green[900]!
          : Colors.blue[900]!;
    }
    return isPinned ? Colors.green[50]! : Colors.blue[50]!;
  }

  static IconData getDocumentIcon(bool isPinned) {
    return isPinned ? Icons.push_pin : Icons.insert_drive_file;
  }

  static String formatDocumentNumber(int mainIndex, int childIndex, bool hasChild) {
    return hasChild ? '$mainIndex.$childIndex' : '$mainIndex.';
  }

  static bool isValidSelection(TextSelection selection, String text) {
    if (selection.isCollapsed) return false;
    if (selection.baseOffset >= text.length || selection.extentOffset >= text.length) return false;
    return true;
  }

  static String extractSelectedText(String text, TextSelection selection) {
    final start = selection.baseOffset < selection.extentOffset 
        ? selection.baseOffset : selection.extentOffset;
    final end = selection.baseOffset < selection.extentOffset 
        ? selection.extentOffset : selection.baseOffset;
    return text.substring(start, end).trim();
  }
}