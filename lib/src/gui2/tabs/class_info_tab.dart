// Translation of pcgen.gui2.tabs.ClassInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

/// Tab for browsing available classes and managing character class levels.
class ClassInfoTab extends StatefulWidget {
  const ClassInfoTab({super.key});

  @override
  State<ClassInfoTab> createState() => ClassInfoTabState();
}

class ClassInfoTabState extends State<ClassInfoTab> {
  PCClass? _selected;
  final TextEditingController _search = TextEditingController();

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
                // Left: class browser
                SizedBox(
                  width: 220,
                  child: _buildList(classes),
                ),
                const VerticalDivider(width: 1),
                // Right: detail + level management
                Expanded(child: _buildDetail(character, dataset)),
              ],
            );
          },
        );
      },
    );
  }

  // ---- Class browser --------------------------------------------------------

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
                      title: Text(cls.getDisplayName(),
                          style: const TextStyle(fontSize: 12)),
                      onTap: () => setState(() => _selected = cls),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---- Class detail + level list --------------------------------------------

  Widget _buildDetail(dynamic character, DataSet? dataset) {
    final cls = _selected;

    // Always show current character levels on the right even without selection
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Class info card (top half)
        if (cls != null)
          _buildClassInfo(cls, character)
        else
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select a class on the left to see details.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ),
        const Divider(height: 1),
        // Level history (bottom half)
        Expanded(child: _buildLevelHistory(character, dataset)),
      ],
    );
  }

  Widget _buildClassInfo(PCClass cls, dynamic character) {
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

    int currentLevel = 0;
    if (character != null) {
      try {
        currentLevel = (character as dynamic).getClassLevel(cls) as int? ?? 0;
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(cls.getDisplayName(),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (character != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Level'),
                      onPressed: () => _addLevel(character, cls),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.remove, size: 16),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red),
                      onPressed: currentLevel == 0
                          ? null
                          : () => _removeLastLevel(character, cls),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 16,
            children: [
              if (abbrev.isNotEmpty) _chip('Abbr', abbrev),
              if (hd.isNotEmpty) _chip('HD', 'd$hd'),
              if (classType.isNotEmpty) _chip('Type', classType),
              _chip('Skill pts/lvl', '${cls.getSkillPtsPerLevel()}'),
              _chip('BAB', cls.getBabProgression().isEmpty ? '?' : cls.getBabProgression()),
              _chip('Fort', cls.isSaveGood('Fortitude') ? 'Good' : 'Poor'),
              _chip('Ref', cls.isSaveGood('Reflex') ? 'Good' : 'Poor'),
              _chip('Will', cls.isSaveGood('Will') ? 'Good' : 'Poor'),
              if (sourceShort.isNotEmpty) _chip('Source', sourceShort),
            ],
          ),
          if (desc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(desc,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
            children: [
              TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              TextSpan(text: value),
            ],
          ),
        ),
      );

  // ---- Level history --------------------------------------------------------

  Widget _buildLevelHistory(dynamic character, DataSet? dataset) {
    if (character == null) {
      return const Center(
        child: Text('No character selected.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      );
    }

    List classLevels = [];
    try {
      classLevels =
          ((character as dynamic).toJson()['classLevels'] as List?) ?? [];
    } catch (_) {}

    if (classLevels.isEmpty) {
      return const Center(
        child: Text('No class levels yet.\nSelect a class and press Add Level.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      );
    }

    int maxHp = 0;
    try { maxHp = (character as dynamic).getMaxHP() as int? ?? 0; } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Text(
                'Class Levels  (${classLevels.length} total'
                '  •  Max HP: $maxHp)',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: const [
              SizedBox(width: 28, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
              Expanded(child: Text('Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
              SizedBox(width: 60, child: Text('HP gained', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey), textAlign: TextAlign.center)),
              SizedBox(width: 48),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: classLevels.length,
            itemBuilder: (context, i) {
              final level = classLevels[i];
              if (level is! Map) return const SizedBox.shrink();
              final className = level['className'] as String? ?? '?';
              final hp = level['hp'] as int? ?? 0;

              // Find class to get HD size for roll/max buttons
              final cls = dataset?.classes
                  .where((c) => c.getKeyName() == level['classKey'])
                  .firstOrNull;
              final hd = int.tryParse(cls?.getHD() ?? '') ?? 8;

              return Container(
                color: i.isEven ? Colors.black.withOpacity(0.02) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ),
                      Expanded(
                        child: Text(className,
                            style: const TextStyle(fontSize: 12)),
                      ),
                      // Editable HP field
                      SizedBox(
                        width: 48,
                        child: _HPField(
                          key: ValueKey('hp_$i'),
                          value: hp,
                          min: 1,
                          max: hd,
                          onChanged: (v) {
                            try {
                              (character as dynamic).setLevelHP(i, v);
                              currentCharacter.notifyListeners();
                              setState(() {});
                            } catch (_) {}
                          },
                        ),
                      ),
                      // Roll and Max buttons
                      SizedBox(
                        width: 48,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'Max (d$hd = $hd)',
                              child: InkWell(
                                onTap: () {
                                  try {
                                    (character as dynamic).setLevelHP(i, hd);
                                    currentCharacter.notifyListeners();
                                    setState(() {});
                                  } catch (_) {}
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.arrow_upward, size: 14,
                                      color: Colors.green),
                                ),
                              ),
                            ),
                            Tooltip(
                              message: 'Roll d$hd',
                              child: InkWell(
                                onTap: () {
                                  try {
                                    final rolled = (character as dynamic)
                                        .rollLevelHP(i, hd) as int;
                                    currentCharacter.notifyListeners();
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Rolled d$hd: $rolled'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  } catch (_) {}
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.casino, size: 14,
                                      color: Colors.blue),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---- Actions --------------------------------------------------------------

  void _addLevel(dynamic character, PCClass cls) {
    try {
      (character as dynamic).addCharacterLevels([cls]);
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding level: $e')),
        );
      }
    }
  }

  void _removeLastLevel(dynamic character, PCClass cls) {
    try {
      // Remove the last level of this specific class
      final levels =
          ((character as dynamic).toJson()['classLevels'] as List?) ?? [];
      for (int i = levels.length - 1; i >= 0; i--) {
        final l = levels[i];
        if (l is Map && l['classKey'] == cls.getKeyName()) {
          levels.removeAt(i);
          break;
        }
      }
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing level: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Small editable HP field
// ---------------------------------------------------------------------------

class _HPField extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _HPField(
      {super.key,
      required this.value,
      required this.min,
      required this.max,
      required this.onChanged});

  @override
  State<_HPField> createState() => _HPFieldState();
}

class _HPFieldState extends State<_HPField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(_HPField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _ctrl.text = '${widget.value}';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commit() {
    final v = int.tryParse(_ctrl.text);
    if (v != null) widget.onChanged(v.clamp(widget.min, widget.max));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      style: const TextStyle(fontSize: 12),
      onSubmitted: (_) => _commit(),
      onEditingComplete: _commit,
    );
  }
}
