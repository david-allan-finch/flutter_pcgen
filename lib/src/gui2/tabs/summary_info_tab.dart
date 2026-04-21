// Translation of pcgen.gui2.tabs.SummaryInfoTab

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'character_info_tab.dart';
import 'tab_title.dart';
import 'todo_handler.dart';
import 'summary/class_level_table_model.dart';
import 'summary/info_pane_handler.dart';
import 'summary/language_table_model.dart';
import 'summary/stat_table_model.dart';

/// The Summary tab — displays key character attributes, stats, class levels,
/// languages and a character info HTML pane.
class SummaryInfoTabWidget extends StatefulWidget implements TodoHandler {
  const SummaryInfoTabWidget({super.key});

  @override
  void adviseTodo(String fieldName) {
    // Delegate to state if mounted.
  }

  @override
  State<SummaryInfoTabWidget> createState() => _SummaryInfoTabState();
}

class _SummaryInfoTabState extends State<SummaryInfoTabWidget>
    implements CharacterInfoTab {
  final TabTitle _tabTitle = TabTitle.withTitle('Summary', null);
  dynamic _character;

  // Models
  StatTableModel? _statModel;
  ClassLevelTableModel? _classLevelModel;
  LanguageTableModel? _languageModel;
  InfoPaneHandler? _infoPaneHandler;

  @override
  TabTitle getTabTitle() => _tabTitle;

  @override
  ModelMap createModels(dynamic character) {
    final models = ModelMap();
    models.put(StatTableModel, StatTableModel(character));
    models.put(ClassLevelTableModel, ClassLevelTableModel(character));
    models.put(LanguageTableModel, LanguageTableModel(character));
    models.put(InfoPaneHandler, InfoPaneHandler(character));
    return models;
  }

  @override
  void restoreModels(ModelMap models) {
    setState(() {
      _statModel = models.get<StatTableModel>(StatTableModel);
      _classLevelModel = models.get<ClassLevelTableModel>(ClassLevelTableModel);
      _languageModel = models.get<LanguageTableModel>(LanguageTableModel);
      _infoPaneHandler = models.get<InfoPaneHandler>(InfoPaneHandler);
      _infoPaneHandler?.install();
    });
  }

  @override
  void storeModels(ModelMap models) {
    _infoPaneHandler?.uninstall();
    _statModel = null;
    _classLevelModel = null;
    _languageModel = null;
    _infoPaneHandler = null;
  }

  void adviseTodo(String fieldName) {
    // Highlight or scroll to the named field.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in: $fieldName')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Character name / alignment / race / class rows
          _buildIdentitySection(),
          const SizedBox(height: 12),
          // Stats table
          _buildStatsSection(),
          const SizedBox(height: 12),
          // Class levels table
          _buildClassLevelsSection(),
          const SizedBox(height: 12),
          // Languages table
          _buildLanguagesSection(),
          const SizedBox(height: 12),
          // Info HTML pane placeholder
          _buildInfoPane(),
        ],
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Identity', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _labelledField('Name', _character?.toString() ?? ''),
            _labelledField('Race', ''),
            _labelledField('Alignment', ''),
            _labelledField('Deity', ''),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_statModel == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _statModel!,
              builder: (context, _) {
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Stat')),
                    DataColumn(label: Text('Base')),
                    DataColumn(label: Text('Mod')),
                  ],
                  rows: List.generate(_statModel!.rowCount, (i) {
                    return DataRow(cells: [
                      DataCell(Text(_statModel!.statName(i))),
                      DataCell(Text(_statModel!.baseScore(i).toString())),
                      DataCell(Text(_statModel!.modifier(i).toString())),
                    ]);
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassLevelsSection() {
    if (_classLevelModel == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class Levels',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _classLevelModel!,
              builder: (context, _) {
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Class')),
                    DataColumn(label: Text('Level')),
                    DataColumn(label: Text('HP')),
                  ],
                  rows: List.generate(_classLevelModel!.rowCount, (i) {
                    return DataRow(cells: [
                      DataCell(Text(_classLevelModel!.className(i))),
                      DataCell(Text(_classLevelModel!.level(i).toString())),
                      DataCell(Text(_classLevelModel!.hp(i).toString())),
                    ]);
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesSection() {
    if (_languageModel == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Languages',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _languageModel!,
              builder: (context, _) {
                return Wrap(
                  spacing: 8,
                  children: List.generate(
                    _languageModel!.languageCount,
                    (i) => Chip(label: Text(_languageModel!.languageName(i))),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPane() {
    return const Card(
      child: SizedBox(
        height: 200,
        child: Center(child: Text('Character Info Sheet')),
      ),
    );
  }

  Widget _labelledField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
