// Translation of pcgen.gui2.tabs.SkillInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

class SkillInfoTab extends StatefulWidget {
  const SkillInfoTab({super.key});

  @override
  State<SkillInfoTab> createState() => SkillInfoTabState();
}

class SkillInfoTabState extends State<SkillInfoTab> {
  dynamic _character;
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
            final skills = dataset?.skills ?? const [];
            final stats = dataset?.stats ?? const [];
            return _buildContent(character, skills, stats);
          },
        );
      },
    );
  }

  Widget _buildContent(dynamic character, List<Skill> skills, List<PCStat> stats) {
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? skills
        : skills.where((s) => s.getDisplayName().toLowerCase().contains(query)).toList();

    final intMod = _statMod(character, 'INT', stats);
    final totalLevels = _totalLevels(character);
    // Use real class skill points from the last class level if available.
    final pool = totalLevels > 0
        ? (_computeSkillPool(character, dataset?.classes ?? [], intMod, totalLevels))
        : 0;
    final spent = _totalRanksSpent(character, skills);
    // Build class skills set for highlighting.
    final classSkillNames = _buildClassSkillNames(character, dataset?.classes ?? []);
    final remaining = pool - spent;

    return Column(
      children: [
        // Header bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Filter skills…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              if (character != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Skill points: $remaining remaining / $pool total',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text('Ranks spent: $spent',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        ),
        // Column headers
        _buildHeader(),
        const Divider(height: 1),
        // Skill rows
        Expanded(
          child: skills.isEmpty
              ? const Center(child: Text('No skills loaded.'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) =>
                      _buildRow(character, filtered[i], stats, i.isEven, classSkillNames),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: const [
          SizedBox(width: 160, child: Text('Skill', style: style)),
          SizedBox(width: 40, child: Text('Stat', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 28, child: Text('Mod', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 80, child: Text('Ranks', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 44, child: Text('Total', style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildRow(dynamic character, Skill skill, List<PCStat> stats, bool shaded,
      Set<String> classSkills) {
    final isClassSkill = classSkills.contains(skill.getDisplayName()) ||
        classSkills.contains(skill.getKeyName());
    final keyStatAbb = _safeKeyStatAbb(skill);
    final statMod = _statMod(character, keyStatAbb, stats);
    final ranks = _getRanks(character, skill);
    final total = ranks + statMod;

    return Container(
      color: shaded ? Colors.black.withOpacity(0.03) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: Row(
                children: [
                  if (isClassSkill)
                    const Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Icon(Icons.star, size: 10, color: Colors.amber),
                    ),
                  Expanded(
                    child: Text(skill.getDisplayName(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isClassSkill ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(keyStatAbb,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ),
            SizedBox(
              width: 28,
              child: Text(_fmtMod(statMod),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
            ),
            SizedBox(
              width: 80,
              child: character == null
                  ? Text('$ranks',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SmallIconButton(
                          icon: Icons.remove,
                          enabled: ranks > 0,
                          onPressed: () => _adjustRanks(character, skill, ranks - 1),
                        ),
                        SizedBox(
                          width: 24,
                          child: Text('$ranks',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12)),
                        ),
                        _SmallIconButton(
                          icon: Icons.add,
                          enabled: true,
                          onPressed: () => _adjustRanks(character, skill, ranks + 1),
                        ),
                      ],
                    ),
            ),
            SizedBox(
              width: 44,
              child: Text(_fmtMod(total),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: total >= 0 ? null : Colors.red,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _adjustRanks(dynamic character, Skill skill, int newRanks) {
    try {
      (character as dynamic).setSkillRanks(skill.getKeyName(), newRanks.clamp(0, 99));
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }

  int _getRanks(dynamic character, Skill skill) {
    if (character == null) return 0;
    try {
      return (character as dynamic).getSkillRanks(skill.getKeyName()) as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  int _statMod(dynamic character, String statAbb, List<PCStat> stats) {
    if (character == null || statAbb.isEmpty) return 0;
    try {
      PCStat? stat;
      for (final s in stats) {
        if (s.getKeyName().toUpperCase() == statAbb.toUpperCase()) {
          stat = s;
          break;
        }
      }
      if (stat == null) return 0;
      return (character as dynamic).getModTotal(stat) as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  int _totalLevels(dynamic character) {
    if (character == null) return 0;
    try {
      return (character as dynamic).getTotalCharacterLevel() as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  int _totalRanksSpent(dynamic character, List<Skill> skills) {
    if (character == null) return 0;
    int total = 0;
    for (final skill in skills) {
      total += _getRanks(character, skill);
    }
    return total;
  }

  String _safeKeyStatAbb(Skill skill) {
    try { return skill.getKeyStatAbb(); } catch (_) { return ''; }
  }

  String _fmtMod(int mod) => mod >= 0 ? '+$mod' : '$mod';

  int _computeSkillPool(dynamic character, List<PCClass> classes, int intMod, int totalLevels) {
    try {
      final levels = (character as dynamic).toJson()['classLevels'];
      if (levels is! List || levels.isEmpty) {
        return ((4 + intMod).clamp(1, 99)) * totalLevels;
      }
      // Sum skill points per class level: (classSPL + INT mod) min 1
      int total = 0;
      final counts = <String, int>{};
      for (final l in levels) {
        if (l is Map) {
          final key = l['classKey'] as String? ?? '';
          counts[key] = (counts[key] ?? 0) + 1;
        }
      }
      for (final entry in counts.entries) {
        final cls = classes.where((c) => c.getKeyName() == entry.key).firstOrNull;
        final spl = cls?.getSkillPtsPerLevel() ?? 4;
        total += ((spl + intMod).clamp(1, 99)) * entry.value;
      }
      return total;
    } catch (_) {
      return ((4 + intMod).clamp(1, 99)) * totalLevels;
    }
  }

  Set<String> _buildClassSkillNames(dynamic character, List<PCClass> classes) {
    final result = <String>{};
    try {
      final levels = (character as dynamic).toJson()['classLevels'];
      if (levels is! List) return result;
      final seenKeys = <String>{};
      for (final l in levels) {
        if (l is Map) {
          final key = l['classKey'] as String? ?? '';
          if (seenKeys.add(key)) {
            final cls = classes.where((c) => c.getKeyName() == key).firstOrNull;
            if (cls != null) {
              final raw = cls.getRawClassSkills();
              if (raw.isNotEmpty) {
                for (final s in raw.split('|')) {
                  if (!s.startsWith('TYPE=')) result.add(s.trim());
                }
              }
            }
          }
        }
      }
    } catch (_) {}
    return result;
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  const _SmallIconButton(
      {required this.icon, required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 14,
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
