// Build History tab — reconstructs level-up choices from PCG data.
//
// When a character has multiple save files (same UUID, or matching
// name+race+firstClass), each file is loaded and the levels are grouped into
// per-save blocks.  Skill rank gains and new equipment are diffed between saves
// and shown on the last level entry of each block.
//
// Data sources:
//   CLASSABILITIESLEVEL → exact level order, HP, skill points, stat bumps.
//   ABILITY:FEAT        → feats in selection order (level estimated from slot rules).
//   SKILL:              → total ranks at save time; diff gives ranks spent per block.
//   EQUIPNAME:          → items present at save time; diff gives new acquisitions.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/facade/core/character_facade.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/io/character_file_io.dart';
import 'package:flutter_pcgen/src/io/pcg_character_io.dart';
import 'package:path/path.dart' as p;

class BuildHistoryTab extends StatefulWidget {
  const BuildHistoryTab({super.key});

  @override
  State<BuildHistoryTab> createState() => _BuildHistoryTabState();
}

class _BuildHistoryTabState extends State<BuildHistoryTab> {
  List<_SaveBlock> _blocks = [];
  bool _loading = true;
  String _statusMsg = 'Scanning save files…';
  final Set<int> _collapsed = {};

  void _setStatus(String msg) {
    if (mounted) setState(() => _statusMsg = msg);
  }

  @override
  void initState() {
    super.initState();
    currentCharacter.addListener(_refresh);
    _refresh();
  }

  @override
  void dispose() {
    currentCharacter.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    final char = currentCharacter.value;
    if (char is! CharacterFacadeImpl) {
      if (mounted) setState(() { _blocks = []; _loading = false; _statusMsg = ''; });
      return;
    }
    if (mounted) setState(() { _loading = true; _statusMsg = 'Scanning save files…'; });
    _load(char).then((blocks) {
      if (mounted) setState(() { _blocks = blocks; _loading = false; _statusMsg = ''; });
    });
  }

  // ─── File loading ──────────────────────────────────────────────────────────

  Future<List<_SaveBlock>> _load(CharacterFacadeImpl char) async {
    final uuid     = char.getCharUuid();
    final charData = char.toJson();
    final charName = char.getName().toLowerCase();
    final charRace = (charData['raceKey'] as String? ?? '').toLowerCase();
    final firstLv  = (charData['classLevels'] as List?)?.whereType<Map>().firstOrNull;
    final charFirst = (firstLv?['classKey'] as String? ??
                       firstLv?['className'] as String? ?? '').toLowerCase();

    final orderedData = <Map<String, dynamic>>[];

    try {
      final dir = Directory(await CharacterFileIO.getCharDir());
      if (dir.existsSync()) {
        final candidates = dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.pcg'))
            .toList();

        _setStatus('Scanning ${candidates.length} file${candidates.length == 1 ? "" : "s"}…');

        final matches = <(int version, String savedAt, DateTime mtime, Map<String, dynamic> data)>[];
        int scanned = 0;
        for (final file in candidates) {
          scanned++;
          final fname = p.basename(file.path);
          _setStatus('Reading $fname ($scanned/${candidates.length})…');
          try {
            final content = await file.readAsString();
            final header  = PCGCharacterIO.peekHeader(content);

            final bool isMatch;
            if (uuid.isNotEmpty) {
              isMatch = header['charUuid'] == uuid;
            } else {
              final hName  = (header['name'] ?? p.basenameWithoutExtension(file.path)).toLowerCase();
              final hRace  = (header['race'] ?? '').toLowerCase();
              final hFirst = (header['firstClass'] ?? '').toLowerCase();
              isMatch = hName == charName &&
                  (hRace.isEmpty  || charRace.isEmpty  || hRace  == charRace) &&
                  (hFirst.isEmpty || charFirst.isEmpty || hFirst == charFirst);
            }

            if (isMatch) {
              _setStatus('Loading $fname…');
              final data    = PCGCharacterIO.parseHistoryData(content);
              final version = data['saveVersion'] as int? ?? 0;
              final mtime   = file.lastModifiedSync();
              // If the file has no embedded timestamp, fall back to filesystem mtime.
              if ((data['savedAt'] as String).isEmpty) {
                data['savedAt'] = mtime.toUtc().toIso8601String();
              }
              final savedAt = data['savedAt'] as String;
              matches.add((version, savedAt, mtime, data));
            }
          } catch (_) {}
        }

        if (matches.isNotEmpty) {
          _setStatus('Found ${matches.length} save${matches.length == 1 ? "" : "s"} — building history…');
        } else {
          _setStatus('No matching saves found — using current character data…');
        }

        matches.sort((a, b) {
          if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
          if (a.$2.isNotEmpty && b.$2.isNotEmpty) return a.$2.compareTo(b.$2);
          return a.$3.compareTo(b.$3);
        });
        orderedData.addAll(matches.map((e) => e.$4));
      }
    } catch (_) {
      _setStatus('Error scanning save directory.');
    }

    if (orderedData.isEmpty) orderedData.add(charData);
    return _buildBlocks(orderedData);
  }

  // ─── History reconstruction ────────────────────────────────────────────────

  List<_SaveBlock> _buildBlocks(List<Map<String, dynamic>> saves) {
    // Authoritative source = save with most levels (not necessarily saves.last,
    // since sort order doesn't guarantee max levels are last).
    final authoritative = saves.reduce((a, b) {
      final aLen = (a['classLevels'] as List? ?? []).length;
      final bLen = (b['classLevels'] as List? ?? []).length;
      return bLen >= aLen ? b : a;
    });
    final allLevels = (authoritative['classLevels'] as List? ?? []).whereType<Map>().toList();
    final allFeats  = ((authoritative['selectedAbilities'] as Map?)?['FEAT'] as List?)
        ?.cast<String>() ?? [];

    final allEntries = _buildAllEntries(allLevels, allFeats);
    if (allEntries.isEmpty) return [];

    // Checkpoints: level count per save, clamped so they never exceed the total
    // and never go below the previous (prevents sublist range errors).
    final rawCheckpoints = saves.map((s) => (s['classLevels'] as List? ?? []).length).toList();
    final checkpoints = <int>[];
    int floor = 0;
    for (final c in rawCheckpoints) {
      final clamped = c.clamp(floor, allEntries.length);
      checkpoints.add(clamped);
      floor = clamped;
    }

    // Baselines for diff computation.
    var prevSkills = <String, double>{};
    var prevEquip  = <String>{};
    var prevFeats  = <String>{};

    final blocks = <_SaveBlock>[];
    int prevLevelCount = 0;

    for (int si = 0; si < saves.length; si++) {
      final data         = saves[si];
      final currCount    = checkpoints[si];
      final blockEntries = allEntries.sublist(prevLevelCount, currCount);

      // ── Skill diffs ──────────────────────────────────────────────────────
      final currSkills = Map<String, double>.from(
          (data['skillRanks'] as Map? ?? {}).cast<String, double>());
      final skillGains  = <String, double>{};
      final skillLosses = <String, double>{};
      for (final e in currSkills.entries) {
        final delta = e.value - (prevSkills[e.key] ?? 0);
        if (delta >  0.01) skillGains[e.key]  =  delta;
        if (delta < -0.01) skillLosses[e.key] = -delta; // stored as positive magnitude
      }
      // Skills present in previous save but gone entirely now.
      for (final e in prevSkills.entries) {
        if (!currSkills.containsKey(e.key)) skillLosses[e.key] = e.value;
      }
      prevSkills = currSkills;

      // ── Equipment diffs ───────────────────────────────────────────────────
      final currEquip    = Set<String>.from((data['equipment'] as List? ?? []).cast<String>());
      final addedItems   = currEquip.difference(prevEquip).toList()..sort();
      final removedItems = prevEquip.difference(currEquip).toList()..sort();
      prevEquip = currEquip;

      // ── Feat diffs ────────────────────────────────────────────────────────
      // The per-level slot estimator already shows feats added; we only surface
      // feats that were REMOVED or whose application target CHANGED.
      final currFeatList = ((data['selectedAbilities'] as Map?)?['FEAT'] as List?)
          ?.cast<String>() ?? [];
      final currFeats = Set<String>.from(currFeatList);
      final removedFeats = prevFeats.difference(currFeats).toList()..sort();
      // Changed feats: same base name but different appliedTo (e.g. Weapon Focus target swapped).
      final changedFeats = <String>[];
      for (final prev in prevFeats) {
        final prevBase = prev.contains('|') ? prev.split('|').first : prev;
        for (final curr in currFeats) {
          final currBase = curr.contains('|') ? curr.split('|').first : curr;
          if (prevBase == currBase && prev != curr && !prevFeats.contains(curr)) {
            final prevApplied = prev.contains('|') ? prev.split('|').last : '';
            final currApplied = curr.contains('|') ? curr.split('|').last : '';
            changedFeats.add('$prevBase: $prevApplied → $currApplied');
          }
        }
      }
      prevFeats = currFeats;

      // ── Apply all diffs to the last level of this block ───────────────────
      if (blockEntries.isNotEmpty) {
        blockEntries.last.skillGains   = skillGains;
        blockEntries.last.skillLosses  = skillLosses;
        blockEntries.last.addedItems   = addedItems;
        blockEntries.last.removedItems = removedItems;
        blockEntries.last.removedFeats = removedFeats;
        blockEntries.last.changedFeats = changedFeats;
      }

      // Block label: use display order when version is 0 (unknown).
      final version    = data['saveVersion'] as int? ?? 0;
      final displayNum = version > 0 ? 'v$version' : '${si + 1}';
      final savedAt    = data['savedAt'] as String? ?? '';
      final dateLabel  = _fmtDate(savedAt);
      final datePart   = dateLabel.isNotEmpty ? ' · $dateLabel' : '';

      final String label;
      if (saves.length == 1) {
        label = 'History$datePart';
      } else if (si == 0) {
        label = 'Initial creation$datePart';
      } else {
        label = 'Save $displayNum$datePart';
      }

      blocks.add(_SaveBlock(
        label: label,
        saveVersion: version,
        savedAt: savedAt,
        levels: blockEntries,
        isSingleFile: saves.length == 1,
      ));

      prevLevelCount = currCount;
    }

    return blocks;
  }

  List<_LevelEntry> _buildAllEntries(List<Map> levelLines, List<String> feats) {
    final result      = <_LevelEntry>[];
    final classCounts = <String, int>{};
    int charLevel = 0;
    int featIdx   = 0;

    for (final l in levelLines) {
      final className = l['classKey'] as String? ?? l['className'] as String? ?? '?';
      final hp        = l['hp']           as int? ?? 0;
      final skills    = l['skillsGained'] as int? ?? 0;
      final statGains = Map<String, int>.from(
          (l['statGains'] as Map?)?.cast<String, int>() ?? {});

      classCounts[className] = (classCounts[className] ?? 0) + 1;
      final classLevel = classCounts[className]!;
      charLevel++;

      final isGeneralFeatLevel = charLevel == 1 || charLevel % 3 == 0;
      final totalSlots = (isGeneralFeatLevel ? 1 : 0) + _classBonusFeatSlots(className, classLevel);

      final featsAtLevel = <String>[];
      for (int i = 0; i < totalSlots && featIdx < feats.length; i++) {
        featsAtLevel.add(feats[featIdx++]);
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

    if (featIdx < feats.length && result.isNotEmpty) {
      result.last.feats.addAll(feats.sublist(featIdx));
    }
    return result;
  }

  int _classBonusFeatSlots(String name, int classLevel) {
    final n = name.toLowerCase();
    if (n.contains('fighter')) {
      if (classLevel == 1 || classLevel == 2) return 1;
      if (classLevel % 2 == 0) return 1;
    }
    if (n.contains('wizard') && classLevel % 5 == 0) return 1;
    if (n.contains('monk') && (classLevel == 1 || classLevel == 2 || classLevel == 6)) return 1;
    return 0;
  }

  String _fmtDate(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays} days ago';
    return '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CharacterFacade?>(
      valueListenable: currentCharacter,
      builder: (context, char, _) {
        if (char == null) return const Center(child: Text('No character loaded.'));
        if (_loading) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(_statusMsg,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          );
        }
        if (_blocks.isEmpty) {
          return const Center(child: Text('No level history found in character file.'));
        }
        return _HistoryView(
          blocks: _blocks,
          collapsed: _collapsed,
          character: char as CharacterFacadeImpl,
          onToggle: (i) => setState(() {
            if (_collapsed.contains(i)) _collapsed.remove(i);
            else _collapsed.add(i);
          }),
        );
      },
    );
  }
}

// ─── Data model ──────────────────────────────────────────────────────────────

class _SaveBlock {
  final String label;
  final int saveVersion;
  final String savedAt;
  final List<_LevelEntry> levels;
  final bool isSingleFile;

  _SaveBlock({
    required this.label,
    required this.saveVersion,
    required this.savedAt,
    required this.levels,
    required this.isSingleFile,
  });
}

class _LevelEntry {
  final int charLevel;
  final String className;
  final int classLevel;
  final int hp;
  final int skillsGained;
  final Map<String, int> statBumps;
  final List<String> feats;
  // Populated only for the last entry of each save block:
  Map<String, double> skillGains   = {};
  Map<String, double> skillLosses  = {};
  List<String> addedItems   = [];
  List<String> removedItems = [];
  List<String> removedFeats = [];
  List<String> changedFeats = [];

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
  final List<_SaveBlock> blocks;
  final Set<int> collapsed;
  final CharacterFacadeImpl character;
  final void Function(int index) onToggle;

  const _HistoryView({
    required this.blocks,
    required this.collapsed,
    required this.character,
    required this.onToggle,
  });

  int get _totalLevels => blocks.fold(0, (s, b) => s + b.levels.length);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(children: [
            Text('Build History — ${character.getName()}',
                style: theme.textTheme.titleSmall),
            const Spacer(),
            Text('$_totalLevels levels · ${blocks.length} ${blocks.length == 1 ? "save" : "saves"}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            itemCount: blocks.length,
            itemBuilder: (context, i) => _BlockCard(
              block: blocks[i],
              index: i,
              isCollapsed: collapsed.contains(i),
              onToggle: () => onToggle(i),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
          child: Text(
            'Feat assignment estimated from standard 3.5e slot rules. '
            'Skills and items shown are changes since the previous save.',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500,
                fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}

class _BlockCard extends StatelessWidget {
  final _SaveBlock block;
  final int index;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const _BlockCard({
    required this.block,
    required this.index,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final levelCount = block.levels.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!block.isSingleFile)
            InkWell(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(6),
                bottom: isCollapsed ? const Radius.circular(6) : Radius.zero,
              ),
              onTap: onToggle,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(6),
                    bottom: isCollapsed ? const Radius.circular(6) : Radius.zero,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
                child: Row(children: [
                  Icon(Icons.save_outlined, size: 15, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(block.label,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                  Text('$levelCount ${levelCount == 1 ? "level" : "levels"}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(width: 4),
                  Icon(isCollapsed ? Icons.expand_more : Icons.expand_less,
                      size: 18, color: Colors.grey.shade500),
                ]),
              ),
            ),

          if (!isCollapsed) ...[
            if (!block.isSingleFile)
              Divider(height: 1, color: Colors.grey.shade200),
            _HeaderRow(),
            Divider(height: 1, color: Colors.grey.shade200),
            ...block.levels.asMap().entries.map(
              (e) => Column(children: [
                _LevelRow(entry: e.value),
                if (e.key < block.levels.length - 1)
                  Divider(height: 1, color: Colors.grey.shade100),
              ]),
            ),
          ],
        ],
      ),
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
        const SizedBox(width: 4),
        Expanded(flex: 3, child: Text('Class', style: s)),
        SizedBox(width: 28, child: Text('Cl', style: s, textAlign: TextAlign.center)),
        SizedBox(width: 36, child: Text('HP', style: s, textAlign: TextAlign.center)),
        SizedBox(width: 40, child: Text('Skills', style: s, textAlign: TextAlign.center)),
        Expanded(flex: 3, child: Text('Abilities', style: s)),
        Expanded(flex: 4, child: Text('Feats', style: s)),
        Expanded(flex: 3, child: Text('Items', style: s)),
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

    // Abilities column: stat bumps + skill gains + skill losses
    final abilityLines = <(String text, Color color)>[
      for (final e in entry.statBumps.entries)
        ('${e.key} +${e.value}', Colors.green.shade700),
      for (final e in entry.skillGains.entries)
        ('${e.key} +${_fmtRank(e.value)}', Colors.teal.shade700),
      for (final e in entry.skillLosses.entries)
        ('${e.key} −${_fmtRank(e.value)}', Colors.orange.shade700),
    ];

    // Feats column: feats taken, removed feats, changed feats
    final featLines = <(String text, Color color)>[
      for (final f in entry.feats) ...[
        (() {
          final base    = f.contains('|') ? f.split('|').first : f;
          final applied = f.contains('|') ? ' (${f.split('|').last})' : '';
          return ('$base$applied', Colors.grey.shade700);
        })(),
      ],
      for (final f in entry.removedFeats)
        ('− ${f.contains('|') ? '${f.split('|').first} (${f.split('|').last})' : f}',
            Colors.red.shade600),
      for (final f in entry.changedFeats)
        ('~ $f', Colors.orange.shade700),
    ];

    // Items column: items added and removed
    final itemLines = <(String text, Color color)>[
      for (final item in entry.addedItems)
        ('+ $item', Colors.indigo.shade400),
      for (final item in entry.removedItems)
        ('− $item', Colors.red.shade400),
    ];

    Widget noteCol(List<(String, Color)> items) {
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((t) => Text(t.$1, style: TextStyle(fontSize: 11, color: t.$2)))
            .toList(),
      );
    }

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
        const SizedBox(width: 4),
        // Class name
        Expanded(
          flex: 3,
          child: Text(entry.className,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        // Class level — its own column
        SizedBox(
          width: 28,
          child: Center(
            child: Text('${entry.classLevel}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ),
        ),
        // HP
        SizedBox(
          width: 36,
          child: Center(
            child: Text('+${entry.hp}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: Colors.red.shade700)),
          ),
        ),
        // Skill points gained this level
        SizedBox(
          width: 40,
          child: Center(
            child: Text(entry.skillsGained > 0 ? '+${entry.skillsGained}' : '—',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
          ),
        ),
        // Abilities: stat bumps + skill rank spends/losses
        Expanded(flex: 3, child: noteCol(abilityLines)),
        // Feats: taken, removed, changed
        Expanded(flex: 4, child: noteCol(featLines)),
        // Items: added and removed
        Expanded(flex: 3, child: noteCol(itemLines)),
      ]),
    );
  }

  String _fmtRank(double r) {
    if (r == r.truncateToDouble()) return r.toInt().toString();
    return r.toStringAsFixed(1);
  }
}
