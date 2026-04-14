// lib/pages/workspace/widgets/glossary_entry_tile.dart

import 'package:flutter/material.dart';
import '../../../entities/glossary_entry/glossary_entry.dart';

class GlossaryEntryTile extends StatefulWidget {
  final GlossaryEntry entry;
  final bool isDarkMode;
  final Color textColor;
  final Color borderColor;
  final Function(String) onUpdateDefinition;
  final VoidCallback onToggleExpand;
  final VoidCallback onDelete;

  const GlossaryEntryTile({
    super.key,
    required this.entry,
    required this.isDarkMode,
    required this.textColor,
    required this.borderColor,
    required this.onUpdateDefinition,
    required this.onToggleExpand,
    required this.onDelete,
  });

  @override
  State<GlossaryEntryTile> createState() => _GlossaryEntryTileState();
}

class _GlossaryEntryTileState extends State<GlossaryEntryTile> {
  late TextEditingController _definitionController;

  @override
  void initState() {
    super.initState();
    // ✅ Создаём контроллер с текущим определением
    _definitionController = TextEditingController(text: widget.entry.definition);
  }

  @override
  void didUpdateWidget(GlossaryEntryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Обновляем контроллер если entry изменился
    if (oldWidget.entry.id != widget.entry.id || 
        oldWidget.entry.definition != widget.entry.definition) {
      _definitionController.text = widget.entry.definition;
    }
  }

  @override
  void dispose() {
    _definitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: widget.borderColor)),
        color: widget.entry.isExpanded
            ? (widget.isDarkMode ? Colors.blue[900]!.withOpacity(0.2) : Colors.blue[50])
            : Colors.transparent,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: Row(
              children: [
                Icon(
                  widget.entry.isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  size: 20,
                  color: widget.textColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.entry.term,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: widget.onDelete,
                  tooltip: 'Удалить',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            onTap: widget.onToggleExpand,
          ),
          if (widget.entry.isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Определение:',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _definitionController,
                    maxLines: 5,
                    minLines: 3,
                    style: TextStyle(color: widget.textColor),
                    decoration: InputDecoration(
                      hintText: 'Введите определение...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                    ),
                    onChanged: widget.onUpdateDefinition,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}