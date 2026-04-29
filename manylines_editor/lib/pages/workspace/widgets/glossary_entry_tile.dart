import 'package:flutter/material.dart';
import '../../../entities/glossary_entry/glossary_entry.dart';

class GlossaryEntryTile extends StatefulWidget {
  final GlossaryEntry entry;
  final bool isDarkMode;
  final Color textColor;
  final Color borderColor;
  final Function(String, String) onUpdateDefinition;
  final Function(String) onToggleDefinition;
  final Function(String, String) onDeleteDefinition;
  final VoidCallback onToggleExpand;

  const GlossaryEntryTile({
    super.key,
    required this.entry,
    required this.isDarkMode,
    required this.textColor,
    required this.borderColor,
    required this.onUpdateDefinition,
    required this.onToggleDefinition,
    required this.onDeleteDefinition,
    required this.onToggleExpand,
  });

  @override
  State<GlossaryEntryTile> createState() => _GlossaryEntryTileState();
}

class _GlossaryEntryTileState extends State<GlossaryEntryTile> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var def in widget.entry.definitions) {
      _controllers[def.id] = TextEditingController(text: def.text);
    }
  }

  @override
  void didUpdateWidget(GlossaryEntryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем контроллеры при изменении определений
    for (var def in widget.entry.definitions) {
      if (!_controllers.containsKey(def.id)) {
        _controllers[def.id] = TextEditingController(text: def.text);
      } else if (_controllers[def.id]!.text != def.text) {
        _controllers[def.id]!.text = def.text;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
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
          // ✅ Заголовок термина
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
              ],
            ),
            onTap: widget.onToggleExpand,
          ),
          
          // ✅ Список определений
          if (widget.entry.isExpanded)
            ...widget.entry.definitions.map((def) => _buildDefinitionTile(def)),
        ],
      ),
    );
  }

  Widget _buildDefinitionTile(GlossaryDefinition def) {
    final isActive = def.isActive;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: isActive 
          ? (widget.isDarkMode ? Colors.green[900]!.withOpacity(0.2) : Colors.green[50])
          : Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Radio button
          Radio<String>(
            value: def.id,
            groupValue: widget.entry.definitions.firstWhere((d) => d.isActive, orElse: () => def).id,
            onChanged: (value) {
              widget.onToggleDefinition(def.id);
            },
            activeColor: Colors.green[700],
          ),
          
          // ✅ Определение
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isActive) ...[
                  // ✅ Активное: показываем TextField для редактирования
                  TextField(
                    controller: _controllers[def.id],
                    maxLines: null,
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
                    onChanged: (value) {
                      widget.onUpdateDefinition(def.id, value);
                    },
                  ),
                ] else ...[
                  // ✅ Неактивное: показываем первую строку с многоточием
                  GestureDetector(
                    onTap: () => widget.onToggleDefinition(def.id),
                    child: Text(
                      _getFirstLine(def.text),
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                
                // ✅ Кнопка удаления
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () {
                      widget.onDeleteDefinition(widget.entry.id, def.id);
                    },
                    tooltip: 'Удалить определение',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFirstLine(String text) {
    final lines = text.split('\n');
    return lines.isNotEmpty ? lines.first : text;
  }
}