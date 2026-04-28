// Translation of pcgen.gui2.csheet.CharacterSheetPanel

import 'package:flutter/material.dart';
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
          // Skills (top 10 by rank)
          _skillsCard(context, theme, data),
          const SizedBox(height: 12),
          // Feats
          _featsCard(context, theme, data),
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
    final scores = data['statScores'] as Map? ?? {};
    const stats = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];

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
              },
              children: stats.map((s) {
                final score = (scores[s] as num?)?.toInt() ?? 10;
                final mod = ((score - 10) / 2).floor();
                return TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('$score', style: const TextStyle(fontSize: 12))),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(mod >= 0 ? '+$mod' : '$mod',
                        style: TextStyle(
                          fontSize: 12,
                          color: mod >= 0 ? Colors.green.shade700 : Colors.red,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ]);
              }).toList(),
            ),
            const Divider(),
            Text('SAVING THROWS', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            _saveRow('Fort', _tryGet(() => (character as dynamic).getFortSave()) as int? ?? 0),
            _saveRow('Ref',  _tryGet(() => (character as dynamic).getRefSave()) as int? ?? 0),
            _saveRow('Will', _tryGet(() => (character as dynamic).getWillSave()) as int? ?? 0),
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
    final level = _tryGet(() => (character as dynamic).getTotalCharacterLevel()) as int? ?? 0;
    final bab = (level * 3 / 4).floor();
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
            _combatRow('BAB', '+$bab (estimate)'),
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
    final counts = <String, int>{};
    for (final l in levels) {
      if (l is Map) counts[l['className'] as String? ?? '?'] = (counts[l['className']] ?? 0) + 1;
    }

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
              children: counts.entries.map((e) => Chip(
                label: Text('${e.key} ${e.value}', style: const TextStyle(fontSize: 12)),
              )).toList(),
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
    if (feats.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FEATS (${feats.length})', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(feats.join(', '), style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  dynamic _tryGet(dynamic Function() fn) {
    try { return fn(); } catch (_) { return null; }
  }
}
