// Translation of pcgen.gui2.tabs.PurchaseInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

// 3.5e standard point buy costs (score → cost).
const _kPBCost = {
  7: -4, 8: -2, 9: -1,
  10: 0, 11: 1, 12: 2, 13: 3,
  14: 5, 15: 7, 16: 10, 17: 13, 18: 17,
};

const _kDefaultStatKeys = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
const _kDefaultPool = 28;

class PurchaseInfoTab extends StatefulWidget {
  const PurchaseInfoTab({super.key});

  @override
  State<PurchaseInfoTab> createState() => PurchaseInfoTabState();
}

class PurchaseInfoTabState extends State<PurchaseInfoTab> {
  dynamic _character;
  int _poolSize = _kDefaultPool;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DataSet?>(
      valueListenable: loadedDataSet,
      builder: (context, dataset, _) {
        return ValueListenableBuilder(
          valueListenable: currentCharacter,
          builder: (context, character, _) {
            final statKeys = (dataset != null && dataset.stats.isNotEmpty)
                ? dataset.stats.map((s) => s.getKeyName()).toList()
                : _kDefaultStatKeys;
            final statObjects = dataset?.stats ?? const <PCStat>[];
            return _buildContent(character, statKeys, statObjects);
          },
        );
      },
    );
  }

  Widget _buildContent(dynamic character, List<String> statKeys, List<PCStat> statObjects) {
    if (character == null) {
      return const Center(child: Text('No character selected.'));
    }

    // Compute point buy score for each stat
    int totalSpent = 0;
    final statScores = <String, int>{};
    for (final key in statKeys) {
      final score = _getScore(character, key, statObjects);
      statScores[key] = score;
      totalSpent += _pbCost(score);
    }
    final remaining = _poolSize - totalSpent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pool size selector
          Row(
            children: [
              const Text('Point Pool:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _poolSize,
                items: [15, 22, 25, 28, 32, 40]
                    .map((p) => DropdownMenuItem(value: p, child: Text('$p')))
                    .toList(),
                onChanged: (v) => setState(() => _poolSize = v ?? _kDefaultPool),
              ),
              const SizedBox(width: 24),
              Text(
                'Spent: $totalSpent  Remaining: $remaining',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: remaining < 0 ? Colors.red : Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stat table
          Table(
            columnWidths: const {
              0: FixedColumnWidth(80),
              1: FixedColumnWidth(60),
              2: FixedColumnWidth(40),
              3: FixedColumnWidth(80),
              4: FixedColumnWidth(50),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
                children: const [
                  Padding(padding: EdgeInsets.all(6), child: Text('Stat', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Mod', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Adjust', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              ...statKeys.map((key) {
                final score = statScores[key] ?? 10;
                final mod = ((score - 10) / 2).floor();
                final cost = _pbCost(score);
                final stat = statObjects.where((s) => s.getKeyName() == key).firstOrNull;
                return TableRow(children: [
                  Padding(padding: const EdgeInsets.all(6), child: Text(key)),
                  Padding(padding: const EdgeInsets.all(6), child: Text('$score', style: const TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: const EdgeInsets.all(6), child: Text(mod >= 0 ? '+$mod' : '$mod')),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _PBButton(
                        icon: Icons.remove,
                        enabled: score > 7,
                        onPressed: () {
                          if (stat != null) {
                            _setScore(character, stat, (score - 1).clamp(7, 18));
                          }
                        },
                      ),
                      _PBButton(
                        icon: Icons.add,
                        enabled: score < 18 && remaining > 0,
                        onPressed: () {
                          if (stat != null) {
                            _setScore(character, stat, (score + 1).clamp(7, 18));
                          }
                        },
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text('$cost',
                        style: TextStyle(
                          color: cost > 0 ? Colors.red.shade700 : Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ]);
              }),
            ],
          ),
          const SizedBox(height: 24),
          // Preset buttons
          Text('Quick Sets', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            _presetButton(character, statObjects, statKeys, 'Standard Array', [15, 14, 13, 12, 10, 8]),
            _presetButton(character, statObjects, statKeys, 'All 10s', [10, 10, 10, 10, 10, 10]),
            _presetButton(character, statObjects, statKeys, 'Elite Array', [18, 14, 12, 12, 10, 8]),
          ]),
        ],
      ),
    );
  }

  Widget _presetButton(dynamic character, List<PCStat> statObjects,
      List<String> statKeys, String label, List<int> scores) {
    return OutlinedButton(
      child: Text(label),
      onPressed: () {
        for (int i = 0; i < statKeys.length && i < scores.length; i++) {
          final stat = statObjects.where((s) => s.getKeyName() == statKeys[i]).firstOrNull;
          if (stat != null) _setScore(character, stat, scores[i]);
        }
      },
    );
  }

  int _getScore(dynamic character, String key, List<PCStat> statObjects) {
    try {
      final stat = statObjects.where((s) => s.getKeyName() == key).firstOrNull;
      if (stat == null) return 10;
      return (character as dynamic).getScoreBase(stat) as int? ?? 10;
    } catch (_) {
      return 10;
    }
  }

  void _setScore(dynamic character, PCStat stat, int score) {
    try {
      (character as dynamic).setScoreBase(stat, score);
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }

  int _pbCost(int score) => _kPBCost[score] ?? 0;
}

class _PBButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  const _PBButton({required this.icon, required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 16,
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
