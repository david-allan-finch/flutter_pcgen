// Translation of pcgen.gui2.csheet.CharacterSheetPanel

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/io/character_text_export.dart';

/// Rendered character sheet panel.
/// Shows a formatted, printable-style character sheet using live character data.
class CharacterSheetPanel extends StatelessWidget {
  final dynamic character;
  const CharacterSheetPanel({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, char, _) {
        final target = char ?? character;
        if (target == null) {
          return const Center(child: Text('No character selected.'));
        }
        return _CharacterSheetView(character: target);
      },
    );
  }
}

class _CharacterSheetView extends StatelessWidget {
  final dynamic character;
  const _CharacterSheetView({required this.character});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _data();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _sheetHeader(context, theme, data),
          const SizedBox(height: 16),
          // Two-column layout: stats + saves on left, combat on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _statsCard(context, theme, data)),
              const SizedBox(width: 12),
              Expanded(child: _combatCard(context, theme, data)),
            ],
          ),
          const SizedBox(height: 12),
          // Class levels
          _classLevelsCard(context, theme, data),
          const SizedBox(height: 12),
          // Skills (top 20 by rank)
          _skillsCard(context, theme, data),
          const SizedBox(height: 12),
          // Feats
          _featsCard(context, theme, data),
          const SizedBox(height: 12),
          // Companions
          _companionsCard(context, theme, data),
          const SizedBox(height: 16),
          // Export button
          Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy Full Sheet to Clipboard'),
              onPressed: character is CharacterFacadeImpl
                  ? () {
                      // Full text export handled by PCGenFrame.showExportDialog()
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Use File > Export for full clipboard export'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _data() {
    try { return (character as dynamic).toJson() as Map<String, dynamic>; }
    catch (_) { return {}; }
  }

  String _name() {
    try { return (character as dynamic).getName() as String? ?? '(unnamed)'; } catch (_) { return '(unnamed)'; }
  }

  Widget _sheetHeader(BuildContext context, ThemeData theme, Map data) {
    final raceRef = _tryGet(() => (character as dynamic).getRaceRef());
    final raceName = _tryGet(() => raceRef?.get()?.getDisplayName()) as String? ?? '—';
    final classes = _tryGet(() => (character as dynamic).getClassLevelSummary()) as String? ?? '—';
    final level = _tryGet(() => (character as dynamic).getTotalCharacterLevel()) as int? ?? 0;
    final hp = _tryGet(() => (character as dynamic).getHP()) as int? ?? 0;
    final align = _tryGet(() => (character as dynamic).getAlignmentKey()) as String? ?? '—';

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_name(),
                style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('$classes  •  Level $level  •  $raceName  •  $align',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer)),
            Text('HP: $hp',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _statsCard(BuildContext context, ThemeData theme, Map data) {
    final baseScores = data['statScores'] as Map? ?? {};
    const statOrder = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];

    // Compute racial bonuses from race object's STAT_BONUS list.
    final racialBonuses = <String, int>{};
    try {
      final race = _tryGet(() => (character as dynamic).getRaceRef()?.get());
      if (race != null) {
        final bonusList = (race as dynamic)
            .getSafeListFor(ListKey.getConstant<String>('STAT_BONUS')) as List?;
        if (bonusList != null) {
          for (final b in bonusList) {
            if (b is String) {
              final idx = b.indexOf(':');
              if (idx > 0) {
                racialBonuses[b.substring(0, idx).toUpperCase()] =
                    (racialBonuses[b.substring(0, idx).toUpperCase()] ?? 0) +
                        (int.tryParse(b.substring(idx + 1)) ?? 0);
              }
            }
          }
        }
      }
    } catch (_) {}

    // Compute saves using class progressions.
    final dataset = loadedDataSet.value;
    final classLevels = data['classLevels'] as List? ?? [];
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }

    int _computeSave(String saveName, String statAbb) {
      final baseScore = (baseScores[statAbb] as num?)?.toInt() ?? 10;
      final racial = racialBonuses[statAbb] ?? 0;
      final statMod = ((baseScore + racial - 10) / 2).floor();
      if (dataset == null) return statMod;
      double base = 0;
      bool hasGood = false;
      for (final entry in counts.entries) {
        final cls = dataset.classes
            .where((c) => c.getKeyName() == entry.key)
            .firstOrNull;
        final isGood = cls?.isSaveGood(saveName) ?? false;
        if (isGood) {
          base += entry.value / 2;
          if (!hasGood) { base += 2; hasGood = true; }
        } else {
          base += entry.value / 3;
        }
      }
      return base.floor() + statMod;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ABILITY SCORES', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(children: [
                  const Text('', style: TextStyle(fontSize: 10)),
                  const Text('Base', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const Text('Total', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const Text('Mod', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ]),
                ...statOrder.map((s) {
                  final base = (baseScores[s] as num?)?.toInt() ?? 10;
                  final racial = racialBonuses[s] ?? 0;
                  final total = base + racial;
                  final mod = ((total - 10) / 2).floor();
                  return TableRow(children: [
                    Padding(padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('$base', style: const TextStyle(fontSize: 12))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('$total',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: racial > 0 ? Colors.blue.shade700
                                  : racial < 0 ? Colors.orange.shade700 : null,
                            ))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(mod >= 0 ? '+$mod' : '$mod',
                            style: TextStyle(
                              fontSize: 12,
                              color: mod >= 0 ? Colors.green.shade700 : Colors.red,
                              fontWeight: FontWeight.bold,
                            ))),
                  ]);
                }),
              ],
            ),
            const Divider(),
            Text('SAVING THROWS', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            _saveRow('Fort', _computeSave('Fortitude', 'CON')),
            _saveRow('Ref',  _computeSave('Reflex',    'DEX')),
            _saveRow('Will', _computeSave('Will',      'WIS')),
          ],
        ),
      ),
    );
  }

  Widget _saveRow(String label, int val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(children: [
      SizedBox(width: 36, child: Text(label, style: const TextStyle(fontSize: 12))),
      Text(val >= 0 ? '+$val' : '$val',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _combatCard(BuildContext context, ThemeData theme, Map data) {
    final scores = data['statScores'] as Map? ?? {};
    final dexScore = (scores['DEX'] as num?)?.toInt() ?? 10;
    final dexMod = ((dexScore - 10) / 2).floor();

    // Compute BAB using class progressions from dataset.
    final dataset = loadedDataSet.value;
    final classLevels = data['classLevels'] as List? ?? [];
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    double babDouble = 0;
    for (final entry in counts.entries) {
      final cls = dataset?.classes
          .where((c) => c.getKeyName() == entry.key)
          .firstOrNull;
      final prog = cls?.getBabProgression() ?? '';
      final rate = prog == 'Full' ? 1.0 : prog == 'Half' ? 0.5 : 0.75;
      babDouble += entry.value * rate;
    }
    final bab = babDouble.floor();
    final babStr = _babSequence(bab);

    final ac = 10 + dexMod;
    final init = dexMod;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMBAT', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _combatRow('AC', '$ac'),
            _combatRow('BAB', babStr),
            _combatRow('Initiative', init >= 0 ? '+$init' : '$init'),
            _combatRow('HP', '${_tryGet(() => (character as dynamic).getHP()) ?? 0}'),
            const Divider(),
            Text('GEAR', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            ...((data['gear'] as List?)?.take(5) ?? []).map((g) =>
                Text('• ${g["name"]} ×${g["qty"] ?? 1}',
                    style: const TextStyle(fontSize: 11))),
            if ((data['gear'] as List? ?? []).length > 5)
              Text('...and ${(data['gear'] as List).length - 5} more',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _combatRow(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(children: [
      SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12))),
      Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _classLevelsCard(BuildContext context, ThemeData theme, Map data) {
    final levels = data['classLevels'] as List? ?? [];
    if (levels.isEmpty) return const SizedBox.shrink();

    // Counts per class + total HP from levels
    final counts = <String, int>{};
    int hpFromLevels = 0;
    for (final l in levels) {
      if (l is Map) {
        final name = l['className'] as String? ?? '?';
        counts[name] = (counts[name] ?? 0) + 1;
        hpFromLevels += (l['hp'] as num?)?.toInt() ?? 0;
      }
    }

    // Add CON modifier per level (from character)
    int conMod = 0;
    try {
      conMod = _tryGet(() => (character as dynamic).getModTotal(
        loadedDataSet.value?.stats.firstWhere(
          (s) => s.getKeyName().toUpperCase() == 'CON',
          orElse: () => throw Exception(),
        ),
      )) as int? ?? 0;
    } catch (_) {}
    final maxHp = (hpFromLevels + conMod * levels.length).clamp(levels.length, 9999);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CLASS LEVELS', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                ...counts.entries.map((e) => Chip(
                  label: Text('${e.key} ${e.value}',
                      style: const TextStyle(fontSize: 12)),
                )),
                if (maxHp > 0)
                  Chip(
                    avatar: const Icon(Icons.favorite, size: 14, color: Colors.red),
                    label: Text('Max HP: $maxHp',
                        style: const TextStyle(fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.red.shade50,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _skillsCard(BuildContext context, ThemeData theme, Map data) {
    final ranks = data['skillRanks'] as Map? ?? {};
    final withRanks = ranks.entries
        .where((e) => (e.value as num? ?? 0) > 0)
        .toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    if (withRanks.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKILLS (with ranks)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: withRanks.take(20).map((e) =>
                  Text('${e.key} ${e.value}',
                      style: const TextStyle(fontSize: 11))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featsCard(BuildContext context, ThemeData theme, Map data) {
    final selected = data['selectedAbilities'] as Map? ?? {};
    final feats = (selected['FEAT'] as List?)?.cast<String>() ?? [];
    // Collect other ability categories too
    final others = <String, List<String>>{};
    for (final entry in selected.entries) {
      if (entry.key != 'FEAT' && entry.value is List) {
        final list = (entry.value as List).cast<String>();
        if (list.isNotEmpty) others[entry.key as String] = list;
      }
    }
    if (feats.isEmpty && others.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feats.isNotEmpty) ...[
              Text('FEATS (${feats.length})', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 2,
                children: feats.map((f) => Chip(
                  label: Text(f, style: const TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
            for (final entry in others.entries) ...[
              const SizedBox(height: 8),
              Text('${entry.key.toUpperCase()} (${entry.value.length})',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(entry.value.join(', '),
                  style: const TextStyle(fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _companionsCard(BuildContext context, ThemeData theme, Map data) {
    final companions = data['companions'] as List? ?? [];
    if (companions.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMPANIONS', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            for (final c in companions)
              if (c is Map)
                Text('${c["name"] ?? "?"} — ${c["type"] ?? ""}',
                    style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  String _babSequence(int bab) {
    if (bab <= 0) return '+0';
    if (bab < 6) return '+$bab';
    final attacks = <String>[];
    int cur = bab;
    while (cur > 0) { attacks.add('+$cur'); cur -= 5; }
    return attacks.join('/');
  }

  dynamic _tryGet(dynamic Function() fn) {
    try { return fn(); } catch (_) { return null; }
  }
}
