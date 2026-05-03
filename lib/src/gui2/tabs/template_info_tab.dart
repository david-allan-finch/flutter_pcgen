// Translation of pcgen.gui2.tabs.TemplateInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

class TemplateInfoTab extends StatefulWidget {
  const TemplateInfoTab({super.key});

  @override
  State<TemplateInfoTab> createState() => TemplateInfoTabState();
}

class TemplateInfoTabState extends State<TemplateInfoTab> {
  PCTemplate? _selected;
  bool _playerOnly = true;
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _templateType(PCTemplate tpl) {
    try {
      final tl = tpl.getSafeListFor(ListKey.getConstant<String>('TYPE'));
      for (final entry in tl.cast<String>()) {
        if (entry.contains(':')) continue;
        final dot = entry.indexOf('.');
        final part = dot > 0 ? entry.substring(0, dot) : entry;
        if (part.isNotEmpty) return part;
      }
    } catch (_) {}
    return 'Other';
  }

  bool _isHidden(PCTemplate tpl) {
    try {
      final v = tpl.getSafeObject(CDOMObjectKey.getConstant<String>('VISIBLE')) as String?;
      return v == 'NO';
    } catch (_) {}
    return false;
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
            final appliedKeys = character != null ? _getAppliedKeys(character) : const <String>[];
            return Row(
              children: [
                SizedBox(width: 240, child: _buildTree(templates, appliedKeys)),
                const VerticalDivider(width: 1),
                Expanded(child: _buildDetail(character, appliedKeys)),
              ],
            );
          },
        );
      },
    );
  }

  // ---- Left: tree view -------------------------------------------------------

  Widget _buildTree(List<PCTemplate> templates, List<String> appliedKeys) {
    final query = _search.text.trim().toLowerCase();
    var filtered = _playerOnly ? templates.where((t) => !_isHidden(t)).toList() : templates;
    if (query.isNotEmpty) {
      filtered = filtered.where((t) => t.getDisplayName().toLowerCase().contains(query)).toList();
    }

    final grouped = <String, List<PCTemplate>>{};
    for (final tpl in filtered) {
      grouped.putIfAbsent(_templateType(tpl), () => []).add(tpl);
    }
    final categories = grouped.keys.toList()..sort();
    for (final cat in categories) {
      grouped[cat]!.sort((a, b) =>
          a.getDisplayName().toLowerCase().compareTo(b.getDisplayName().toLowerCase()));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
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
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('Visible', style: TextStyle(fontSize: 11)),
              selected: _playerOnly,
              onSelected: (v) => setState(() => _playerOnly = v),
              visualDensity: VisualDensity.compact,
              tooltip: 'Hide VISIBLE:NO templates',
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
                '${filtered.length} templates in ${categories.length} types',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        Expanded(
          child: templates.isEmpty
              ? const Center(child: Text('No templates loaded.'))
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, ci) {
                    final cat = categories[ci];
                    final items = grouped[cat]!;
                    return ExpansionTile(
                      key: PageStorageKey('tpl_$cat'),
                      initiallyExpanded: query.isNotEmpty || categories.length <= 5,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(cat,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      trailing: Text('${items.length}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      children: items.map((tpl) {
                        final isApplied = appliedKeys.contains(tpl.getKeyName());
                        return ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.only(left: 28, right: 8),
                          selected: _selected == tpl,
                          selectedTileColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(80),
                          tileColor: isApplied
                              ? Colors.blue.withOpacity(0.06)
                              : null,
                          title: Text(tpl.getDisplayName(),
                              style: const TextStyle(fontSize: 12)),
                          trailing: isApplied
                              ? const Icon(Icons.check_circle,
                                  color: Colors.blue, size: 14)
                              : null,
                          onTap: () => setState(() => _selected = tpl),
                        );
                      }).toList(),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---- Right: detail + applied list -----------------------------------------

  Widget _buildDetail(dynamic character, List<String> appliedKeys) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selected != null && character != null)
          _buildSelectedInfo(_selected!, character, appliedKeys)
        else
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select a template on the left to see details.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ),
        const Divider(height: 1),
        Expanded(child: _buildAppliedList(character, appliedKeys)),
      ],
    );
  }

  Widget _buildSelectedInfo(
      PCTemplate tpl, dynamic character, List<String> appliedKeys) {
    final isApplied = appliedKeys.contains(tpl.getKeyName());
    String sourceStr = '';
    try {
      final uri = tpl.getSourceURI();
      if (uri != null) sourceStr = Uri.parse(uri).pathSegments.last;
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(tpl.getDisplayName(),
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Apply'),
              onPressed: isApplied
                  ? null
                  : () => _applyTemplate(character, tpl.getKeyName()),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.remove, size: 14),
              label: const Text('Remove'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: isApplied
                  ? () => _removeTemplate(character, tpl.getKeyName())
                  : null,
            ),
          ]),
          if (sourceStr.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(sourceStr,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          const SizedBox(height: 4),
          Wrap(spacing: 12, children: [
            _chip('Type', _templateType(tpl)),
            if (isApplied) _chip('Status', 'Applied'),
          ]),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12),
            children: [
              TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              TextSpan(
                  text: value,
                  style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      );

  Widget _buildAppliedList(dynamic character, List<String> appliedKeys) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Text(
            'Applied Templates (${appliedKeys.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const Divider(height: 1),
        if (appliedKeys.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No templates applied.',
                  style:
                      TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
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
                  subtitle: tpl != null
                      ? Text(_templateType(tpl),
                          style: const TextStyle(fontSize: 11))
                      : null,
                  trailing: character == null
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 16, color: Colors.red),
                          onPressed: () => _removeTemplate(character, key),
                        ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ---- Actions ---------------------------------------------------------------

  List<String> _getAppliedKeys(dynamic character) {
    try {
      return (character as dynamic).getAppliedTemplateKeys() as List<String>? ?? [];
    } catch (_) {
      return [];
    }
  }

  void _applyTemplate(dynamic character, String key) {
    try {
      (character as dynamic).applyTemplateKey(key);
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }

  void _removeTemplate(dynamic character, String key) {
    try {
      (character as dynamic).removeTemplateKey(key);
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }
}
