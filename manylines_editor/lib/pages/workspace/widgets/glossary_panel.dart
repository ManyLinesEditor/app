import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/document/document_repository.dart';
import '../../../entities/project/project_repository.dart';
import '../../../entities/setting/setting_repository.dart';
import '../../../features/glossary/add_entry.dart';
import '../../../features/glossary/edit_entry.dart';
import '../../../features/glossary/delete_entry.dart';
import '../../../features/glossary/toggle_entry.dart';
import 'glossary_entry_tile.dart';

class GlossaryPanel extends StatelessWidget {
  const GlossaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final documentState = context.watch<DocumentRepository>();
    final projectState = context.watch<ProjectRepository>();
    final settingState = context.watch<SettingRepository>();
    
    final document = documentState.selectedDocument;
    final isDarkMode = settingState.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    if (document == null) {
      return Container(
        width: 300,
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        child: const Center(child: Text('Выберите документ')),
      );
    }

    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: borderColor)),
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      ),
      child: Column(
        children: [
          _buildHeader(document.name, textColor, context),
          if (documentState.selectedTextForGlossary != null)
            _buildAddEntrySection(documentState.selectedTextForGlossary!, textColor, isDarkMode, context),
          Expanded(
            child: document.glossary.isEmpty
                ? _buildEmptyState(isDarkMode)
                : ListView.builder(
                    itemCount: document.glossary.length,
                    itemBuilder: (context, index) {
                      final entry = document.glossary[index];
                      return GlossaryEntryTile(
                        entry: entry,
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        borderColor: borderColor,
                        onUpdateDefinition: (definition) => 
                            EditGlossaryEntryFeature.execute(context, entry.id, definition),
                        onToggleExpand: () => ToggleGlossaryEntryFeature.execute(context, entry.id),
                        onDelete: () => DeleteGlossaryEntryFeature.execute(context, entry.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String documentName, Color textColor, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: context.watch<SettingRepository>().isDarkMode ? Colors.grey[800] : Colors.grey[200],
      child: Row(
        children: [
          const Icon(Icons.book, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              documentName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEntrySection(
    String selectedText, Color textColor, bool isDarkMode, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: isDarkMode ? Colors.green[900]!.withOpacity(0.3) : Colors.green[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Выделенный текст:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              border: Border.all(color: Colors.green[700]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(selectedText, style: TextStyle(color: textColor)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => AddGlossaryEntryFeature.execute(
                context, selectedText, context.watch<DocumentRepository>().selectedDocument!.id),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Добавить в глоссарий'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Глоссарий пуст', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            'Выделите текст и свайпните влево',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}