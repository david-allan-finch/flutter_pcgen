// Build History tab — reconstructs level-up choices from PCG data.
//
// Data sources:
//   CLASSABILITIESLEVEL lines → exact levelling order, HP rolled, skill points,
//                                stat bumps (PRESTAT). Fully reliable.
//   ABILITY:FEAT lines        → feats in selection order. Order is reliable;
//                                exact level of each feat is estimated from
//                                standard feat-slot rules per class/level.
//   SKILL lines               → total ranks by class only (no per-level detail).

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/facade/core/character_facade.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class BuildHistoryTab extends StatelessWidget {
  const BuildHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CharacterFacade?>(
      valueListenable: currentCharacter,
      builder: (context, char, _) {
        if (char is! CharacterFacadeImpl) {
          return const Center(child: Text('No character loaded.'));
        }
        final history = _buildHistory(char);
        if (history.isEmpty) {
          return const Center(child: Text('No level history found in character file.'));
        }
        return _HistoryView(history: history, character: char);
      },
    );
  }

  List<_LevelEntry> _buildHistory(CharacterFacadeImpl char) {
    final data       = char.toJson();
    final classLevels = (data['classLevels'] as List? ?? []).whereType<Map>().toList();
    if (classLevels.isEmpty) return [];

    // Ordered list of feats (FEAT category) in selection order.
    final allFeats = ((data['selectedAbilities'] as Map?)?['FEAT'] as List?)
        ?.cast<String>() ?? [];
    // Non-FEAT abilities in selection order (class features, special abilities).
    final specialAbilities = <String>[];
    ((data['selectedAbilities'] as Map?) ?? {}).forEach((cat, list) {
      if (cat != 'FEAT' && list is List) {
        for (final k in list) {
          if (!k.toString().contains('+1 Feat')) specialAbilities.add(k.toString());
        }
      }
    });

    // Reconstruct feat slot counts by character level so we can assign feats
    // to the levels they were most likely chosen.
    // We track: how many general feat slots have fired, then pull from allFeats.
    final result = <_LevelEntry>[];
    final classCounts = <String, int>{};   // running count per class
    int charLevel = 0;
    int featIdx   = 0; // index into allFeats for next unassigned feat

    for (final l in classLevels) {
      final className   = l['classKey'] as String? ?? l['className'] as String? ?? '?';
      final hp          = l['hp']          as int? ?? 0;
      final skills      = l['skillsGained'] as int? ?? 0;
      final statGains   = Map<String, int>.from(
          (l['statGains'] as Map?)?.cast<String, int>() ?? {});

      classCounts[className] = (classCounts[className] ?? 0) + 1;
      final classLevel = classCounts[className]!;
      charLevel++;

      // Determine how many feat slots fire at this character level.
      // Standard 3.5e: level 1, then every 3 levels (3, 6, 9…).
      final isGeneralFeatLevel = charLevel == 1 || charLevel % 3 == 0;
      final featSlots = isGeneralFeatLevel ? 1 : 0;
      // Class bonus feats (rough approximation for Fighter/Monk/Wizard etc.)
      final bonusFeatSlots = _classBonusFeatSlots(className, classLevel);

      final totalFeatSlots = featSlots + bonusFeatSlots;
      final featsAtLevel = <String>[];
      for (int i = 0; i < totalFeatSlots && featIdx < allFeats.length; i++) {
        featsAtLevel.add(allFeats[featIdx++]);
      }

      result.add(_LevelEntry(
        charLevel: charLevel,
        className: className,
        classLevel: classLevel,
        hp: hp,
        skillsGained: skills,
        statBumps: statGains,
        feats: featsAtLevel,
      ));
    }

    // Any remaining feats that weren't slotted (edge cases) go on the last level.
    if (featIdx < allFeats.length && result.isNotEmpty) {
      result.last.feats.addAll(allFeats.sublist(featIdx));
    }

    return result;
  }

  /// Returns the number of class bonus feat slots at [classLevel] for [className].
  /// This is a best-effort approximation of common 3.5e classes.
  int _classBonusFeatSlots(String name, int classLevel) {
    final n = name.toLowerCase();
    // Fighter: bonus feat at 1, 2, then every even level
    if (n.contains('fighter')) {
      if (classLevel == 1 || classLevel == 2) return 1;
      if (classLevel % 2 == 0) return 1;
    }
    // Wizard: bonus feat at 5, 10, 15, 20
    if (n.contains('wizard') && classLevel % 5 == 0) return 1;
    // Monk: bonus feat at 1, 2, 6
    if (n.contains('monk') && (classLevel == 1 || classLevel == 2 || classLevel == 6)) return 1;
    return 0;
  }
}

// ─── Data model ──────────────────────────────────────────────────────────────

class _LevelEntry {
  final int charLevel;
  final String className;
  final int classLevel;
  final int hp;
  final int skillsGained;
  final Map<String, int> statBumps;
  final List<String> feats;

  _LevelEntry({
    required this.charLevel,
    required this.className,
    required this.classLevel,
    required this.hp,
    required this.skillsGained,
    required this.statBumps,
    required this.feats,
  });
}

// ─── UI ──────────────────────────────────────────────────────────────────────

class _HistoryView extends StatelessWidget {
  final List<_LevelEntry> history;
  final CharacterFacadeImpl character;

  const _HistoryView({required this.history, required this.character});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(children: [
            Text('Build History — ${character.getName()}',
                style: theme.textTheme.titleSmall),
            const Spacer(),
            Text('${history.length} levels',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ]),
        ),
        const Divider(height: 1),
        // Column headers
        _HeaderRow(),
        const Divider(height: 1),
        // Level rows
        Expanded(
          child: ListView.separated(
            itemCount: history.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, i) => _LevelRow(entry: history[i]),
          ),
        ),
        // Note about feat ordering
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
          child: Text(
            'Feat assignment is estimated from standard 3.5e feat-slot rules. '
            'Skill totals are shown per class, not per level.',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500,
                fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const s = TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(children: [
        SizedBox(width: 34, child: Text('Lvl', style: s, textAlign: TextAlign.center)),
        const SizedBox(width: 6),
        Expanded(flex: 3, child: Text('Class', style: s)),
        SizedBox(width: 36, child: Text('HP', style: s, textAlign: TextAlign.center)),
        SizedBox(width: 36, child: Text('SP', style: s, textAlign: TextAlign.center)),
        Expanded(flex: 4, child: Text('Notes', style: s)),
      ]),
    );
  }
}

class _LevelRow extends StatelessWidget {
  final _LevelEntry entry;
  const _LevelRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isAltRow = entry.charLevel % 2 == 0;
    final notes = <String>[
      ...entry.statBumps.entries.map((e) =>
          '${e.key} +${e.value}'),
      ...entry.feats.map((f) {
        final base = f.contains('|') ? f.split('|').first : f;
        final applied = f.contains('|') ? ' (${f.split('|').last})' : '';
        return 'Feat: $base$applied';
      }),
    ];

    return Container(
      color: isAltRow ? Colors.grey.shade50 : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Character level badge
        SizedBox(
          width: 34,
          child: Center(
            child: Container(
              width: 26, height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text('${entry.charLevel}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onPrimaryContainer)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Class name + class level
        Expanded(
          flex: 3,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.className,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('(${entry.className} ${entry.classLevel})',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ]),
        ),
        // HP
        SizedBox(
          width: 36,
          child: Center(
            child: Text('+${entry.hp}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700)),
          ),
        ),
        // Skill points
        SizedBox(
          width: 36,
          child: Center(
            child: Text(entry.skillsGained > 0 ? '+${entry.skillsGained}' : '—',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
          ),
        ),
        // Notes: stat bumps + feats
        Expanded(
          flex: 4,
          child: notes.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: notes.map((n) {
                    final isStatBump = entry.statBumps.keys.any(
                        (k) => n.startsWith(k));
                    return Text(n,
                        style: TextStyle(
                            fontSize: 11,
                            color: isStatBump
                                ? Colors.green.shade700
                                : Colors.grey.shade700));
                  }).toList(),
                ),
        ),
      ]),
    );
  }
}
