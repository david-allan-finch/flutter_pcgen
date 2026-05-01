// Translation of pcgen.gui2.tabs.SkillInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
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
            final classes = dataset?.classes ?? const <PCClass>[];
            return _buildContent(character, skills, stats, classes);
          },
        );
      },
    );
  }

  Widget _buildContent(dynamic character, List<Skill> skills, List<PCStat> stats, List<PCClass> classes) {
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? skills
        : skills.where((s) => s.getDisplayName().toLowerCase().contains(query)).toList();

    final intMod = _statMod(character, 'INT', stats);
    final totalLevels = _totalLevels(character);
    final modSkillBonus = _getSkillPointBonus(character);
    final pool = totalLevels > 0
        ? (_computeSkillPool(character, classes, intMod, totalLevels) + modSkillBonus)
        : 0;
    final classSkillNames = _buildClassSkillNames(character, classes);
    // Cross-class costs: class skills cost 1pt/rank, cross-class cost 2pt/rank
    final spent = _totalPointsSpent(character, skills, classSkillNames);
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
                    Text(
                      '$remaining / $pool pts remaining',
                      style: TextStyle(
                        fontSize: 11,
                        color: remaining < 0
                            ? Colors.red.shade700
                            : Colors.grey.shade700,
                        fontWeight: remaining < 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text('C = class skill (1pt)  CC = cross-class (2pt)',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
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
          SizedBox(width: 24, child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey))),
          SizedBox(width: 148, child: Text('Skill', style: style)),
          SizedBox(width: 36, child: Text('Stat', style: style, textAlign: TextAlign.center)),
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
    final skillBonus = _getSkillBonus(character, skill.getDisplayName(), skill.getKeyName());
    final acp = skill.hasArmorCheckPenalty() ? _getACP(character) : 0;
    final total = ranks + statMod + skillBonus + acp;

    return Container(
      color: shaded ? Colors.black.withOpacity(0.03) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            // Class/cross-class badge
            SizedBox(
              width: 24,
              child: Text(
                isClassSkill ? 'C' : 'CC',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isClassSkill ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ),
            SizedBox(
              width: 148,
              child: Row(
                children: [
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
              width: 36,
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

  // Cross-class skills cost 2 points per rank; class skills cost 1.
  int _totalPointsSpent(dynamic character, List<Skill> skills, Set<String> classSkillNames) {
    if (character == null) return 0;
    int total = 0;
    for (final skill in skills) {
      final ranks = _getRanks(character, skill);
      if (ranks == 0) continue;
      final isClass = classSkillNames.contains(skill.getDisplayName()) ||
          classSkillNames.contains(skill.getKeyName());
      total += isClass ? ranks : ranks * 2;
    }
    return total;
  }

  int _getSkillPointBonus(dynamic character) {
    if (character == null) return 0;
    try { return (character as dynamic).getSkillPointBonus() as int? ?? 0; } catch (_) { return 0; }
  }

  String _safeKeyStatAbb(Skill skill) {
    try { return skill.getKeyStatAbb(); } catch (_) { return ''; }
  }

  int _getSkillBonus(dynamic character, String displayName, String keyName) {
    if (character == null) return 0;
    try {
      return (character as dynamic).getSkillBonus(displayName, keyName) as int? ?? 0;
    } catch (_) { return 0; }
  }

  int _getACP(dynamic character) {
    if (character == null) return 0;
    try {
      return (character as dynamic).getArmorCheckPenalty() as int? ?? 0;
    } catch (_) { return 0; }
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
            if (cls == null) continue;

            // Prefer the structured CLASS_SKILLS list (populated from CSKILL token)
            try {
              final skillList = cls.getSafeListFor(
                  ListKey.getConstant<String>('CLASS_SKILLS')) as List?;
              if (skillList != null && skillList.isNotEmpty) {
                for (final s in skillList) {
                  if (s is String && s.isNotEmpty) result.add(s);
                }
                continue; // skip raw fallback if structured list found
              }
            } catch (_) {}

            // Fallback: parse the raw CSKILL string
            final raw = cls.getRawClassSkills();
            if (raw.isNotEmpty) {
              for (final s in raw.split('|')) {
                if (s.isNotEmpty && !s.startsWith('TYPE=')) result.add(s.trim());
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
