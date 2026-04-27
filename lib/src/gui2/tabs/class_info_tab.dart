// Translation of pcgen.gui2.tabs.ClassInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

/// Tab for browsing available classes and adding levels to the character.
class ClassInfoTab extends StatefulWidget {
  const ClassInfoTab({super.key});

  @override
  State<ClassInfoTab> createState() => ClassInfoTabState();
}

class ClassInfoTabState extends State<ClassInfoTab> {
  dynamic _character;
  PCClass? _selected;
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
        final classes = dataset?.classes ?? const [];
        return Row(
          children: [
            Expanded(child: _buildList(classes)),
            const VerticalDivider(width: 1),
            Expanded(child: _buildDetail()),
          ],
        );
      },
    );
  }

  Widget _buildList(List<PCClass> classes) {
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? classes
        : classes
            .where((c) => c.getDisplayName().toLowerCase().contains(query))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Filter classes…',
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
            child: Text('${filtered.length} classes',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        Expanded(
          child: classes.isEmpty
              ? const Center(child: Text('No classes loaded.'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final cls = filtered[i];
                    final selected = _selected == cls;
                    return ListTile(
                      dense: true,
                      selected: selected,
                      title: Text(cls.getDisplayName()),
                      onTap: () => setState(() => _selected = cls),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDetail() {
    final cls = _selected;
    if (cls == null) {
      return const Center(child: Text('Select a class to see details.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cls.getDisplayName(),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _row('Key', cls.getKeyName()),
          if (cls.getSourceURI() != null)
            _row('Source', Uri.parse(cls.getSourceURI()!).pathSegments.last),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(
              width: 80,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ]),
      );
}
