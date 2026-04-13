import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/project/project_repository.dart';
import '../../../entities/setting/setting_repository.dart';
import '../../../features/document/create_document.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final settingState = context.watch<SettingRepository>();
    final isPanelCollapsed = settingState.isSidePanelCollapsed;
    
    final leftPanelBg = settingState.isDarkMode ? Colors.grey[900] : Colors.white;
    final headerBg = settingState.isDarkMode ? Colors.green[900] : Colors.green[50];
    final textColor = settingState.isDarkMode ? Colors.white : Colors.black87;
    final borderColor = settingState.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isPanelCollapsed ? 0 : 300,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: isPanelCollapsed
          ? const SizedBox.shrink()
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: headerBg,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => projectState.clearSelectedProject(),
                        tooltip: 'Back to projects',
                      ),
                      Expanded(
                        child: Text(
                          projectState.selectedProject?.name ?? '',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Material(
                    color: leftPanelBg,
                    child: Column(
                      children: [
                        Expanded(

                          child: Selector<SettingRepository, bool>(
                            selector: (_, state) => state.isGraphView,
                            builder: (context, isGraphView, _) {
                              return isGraphView 
                                  ? const _DocumentsGraph() 
                                  : const _DocumentsList();
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: borderColor)),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => CreateDocumentFeature.show(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Новый документ'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                foregroundColor: settingState.isDarkMode ? Colors.white : Colors.green[700],
                                side: BorderSide(
                                  color: settingState.isDarkMode ? Colors.green[400]! : Colors.green[700]!,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DocumentsList extends StatelessWidget {
  const _DocumentsList();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Documents List'));
}

class _DocumentsGraph extends StatelessWidget {
  const _DocumentsGraph();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Documents Graph'));
}