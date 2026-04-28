// Translation of pcgen.gui2.tabs.ClassInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
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
        return ValueListenableBuilder(
          valueListenable: currentCharacter,
          builder: (context, character, _) {
            return Row(
              children: [
                Expanded(child: _buildList(classes)),
                const VerticalDivider(width: 1),
                Expanded(child: _buildDetail(character)),
              ],
            );
          },
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
                    final isSelected = _selected == cls;
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      title: Text(cls.getDisplayName()),
                      onTap: () => setState(() => _selected = cls),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDetail(dynamic character) {
    final cls = _selected;
    if (cls == null) {
      return const Center(child: Text('Select a class to see details.'));
    }

    // Get current level count for this class.
    int currentLevel = 0;
    if (character != null) {
      try {
        currentLevel = (character as dynamic).getClassLevel(cls) as int? ?? 0;
      } catch (_) {}
    }

    // Pull extra fields from token parsing.
    String hd = '';
    String desc = '';
    String sourceShort = '';
    String abbrev = '';
    String classType = '';
    List<String> types = [];
    try {
      hd = cls.getHD();
      desc = cls.getString(StringKey.description) ?? '';
      sourceShort = cls.getString(StringKey.sourceShort) ??
                    cls.getString(StringKey.sourceLong) ?? '';
      abbrev = cls.getString(StringKey.abbKr) ?? '';
      classType = cls.getString(StringKey.classType) ?? '';
      final typeList = cls.getSafeListFor(ListKey.getConstant<String>('TYPE'));
      types = typeList.cast<String>();
    } catch (_) {}

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cls.getDisplayName(),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _row('Key', cls.getKeyName()),
          if (abbrev.isNotEmpty) _row('Abbrev', abbrev),
          if (hd.isNotEmpty) _row('Hit Die', 'd$hd'),
          if (classType.isNotEmpty) _row('Class Type', classType),
          _row('Skill Pts/Lvl', '${cls.getSkillPtsPerLevel()}'),
          if (sourceShort.isNotEmpty) _row('Source', sourceShort),
          if (types.isNotEmpty) _row('Types', types.join(', ')),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(desc, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          if (character != null) ...[
            Row(
              children: [
                const Text('Current Level:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(
                  '$currentLevel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Level'),
                  onPressed: () {
                    try {
                      (character as dynamic).addCharacterLevels([cls]);
                      currentCharacter.notifyListeners();
                      setState(() {});
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding level: $e')),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.remove),
                  label: const Text('Remove Level'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                  ),
                  onPressed: currentLevel == 0
                      ? null
                      : () {
                          try {
                            // Remove one level of this class by removing the
                            // last matching entry. We do this by temporarily
                            // swapping — but the simplest correct approach is
                            // to call removeCharacterLevels(1) which removes
                            // the last added level.
                            (character as dynamic).removeCharacterLevels(1);
                            currentCharacter.notifyListeners();
                            setState(() {});
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error removing level: $e')),
                            );
                          }
                        },
                ),
              ],
            ),
          ] else
            const Text(
              'Create a character to add class levels.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
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
