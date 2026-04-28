// Translation of pcgen.gui2.tabs.TemplateInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

class TemplateInfoTab extends StatefulWidget {
  const TemplateInfoTab({super.key});

  @override
  State<TemplateInfoTab> createState() => TemplateInfoTabState();
}

class TemplateInfoTabState extends State<TemplateInfoTab> {
  dynamic _character;
  PCTemplate? _selected;
  final TextEditingController _search = TextEditingController();

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DataSet?>(
      valueListenable: loadedDataSet,
      builder: (context, dataset, _) {
        return ValueListenableBuilder(
          valueListenable: currentCharacter,
          builder: (context, character, _) {
            final templates = dataset?.templates ?? const <PCTemplate>[];
            return _buildContent(character, templates);
          },
        );
      },
    );
  }

  Widget _buildContent(dynamic character, List<PCTemplate> templates) {
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? templates
        : templates.where((t) => t.getDisplayName().toLowerCase().contains(query)).toList();

    final appliedKeys = character != null ? _getAppliedKeys(character) : const <String>[];

    return Row(
      children: [
        // Available panel
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Filter templates…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Available (${filtered.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              Expanded(
                child: templates.isEmpty
                    ? const Center(child: Text('No templates loaded.'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final tpl = filtered[i];
                          final isSelected = _selected == tpl;
                          final isApplied = appliedKeys.contains(tpl.getKeyName());
                          return ListTile(
                            dense: true,
                            selected: isSelected,
                            title: Text(tpl.getDisplayName(),
                                style: const TextStyle(fontSize: 12)),
                            tileColor: isApplied ? Colors.blue.withOpacity(0.07) : null,
                            trailing: isApplied
                                ? const Icon(Icons.check_circle, color: Colors.blue, size: 16)
                                : null,
                            onTap: () => setState(() => _selected = tpl),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Detail / applied panel
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text('Applied Templates (${appliedKeys.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              if (_selected != null && character != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selected!.getDisplayName(),
                          style: Theme.of(context).textTheme.titleSmall),
                      if (_selected!.getSourceURI() != null)
                        Text(Uri.parse(_selected!.getSourceURI()!).pathSegments.last,
                            style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Apply'),
                            onPressed: appliedKeys.contains(_selected!.getKeyName())
                                ? null
                                : () => _applyTemplate(character, _selected!.getKeyName()),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.remove, size: 14),
                            label: const Text('Remove'),
                            onPressed: appliedKeys.contains(_selected!.getKeyName())
                                ? () => _removeTemplate(character, _selected!.getKeyName())
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const Divider(),
              Expanded(
                child: appliedKeys.isEmpty
                    ? const Center(
                        child: Text('No templates applied.',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
                    : ListView.builder(
                        itemCount: appliedKeys.length,
                        itemBuilder: (context, i) {
                          final key = appliedKeys[i];
                          final tpl = (loadedDataSet.value?.templates ?? [])
                              .where((t) => t.getKeyName() == key)
                              .firstOrNull;
                          return ListTile(
                            dense: true,
                            title: Text(tpl?.getDisplayName() ?? key,
                                style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 16, color: Colors.red),
                              onPressed: character == null
                                  ? null
                                  : () => _removeTemplate(character, key),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _getAppliedKeys(dynamic character) {
    try { return (character as dynamic).getAppliedTemplateKeys() as List<String>? ?? []; }
    catch (_) { return []; }
  }

  void _applyTemplate(dynamic character, String key) {
    try { (character as dynamic).applyTemplateKey(key); currentCharacter.notifyListeners(); setState(() {}); }
    catch (_) {}
  }

  void _removeTemplate(dynamic character, String key) {
    try { (character as dynamic).removeTemplateKey(key); currentCharacter.notifyListeners(); setState(() {}); }
    catch (_) {}
  }
}
