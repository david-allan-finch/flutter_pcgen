//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.tabs.PurchaseInfoTab

import 'package:flutter/material.dart';

/// Tab panel for purchasing ability scores using point-buy.
class PurchaseInfoTab extends StatefulWidget {
  const PurchaseInfoTab({super.key});

  @override
  State<PurchaseInfoTab> createState() => PurchaseInfoTabState();
}

class PurchaseInfoTabState extends State<PurchaseInfoTab> {
  dynamic _character;
  final List<_StatEntry> _stats = [
    _StatEntry('STR', 10),
    _StatEntry('DEX', 10),
    _StatEntry('CON', 10),
    _StatEntry('INT', 10),
    _StatEntry('WIS', 10),
    _StatEntry('CHA', 10),
  ];

  void setCharacter(dynamic character) => setState(() => _character = character);

  int get _totalCost => _stats.fold(0, (sum, s) => sum + _costForScore(s.score));

  int _costForScore(int score) {
    if (score <= 8) return 0;
    if (score == 9) return 1;
    if (score == 10) return 2;
    if (score == 11) return 3;
    if (score == 12) return 4;
    if (score == 13) return 5;
    if (score == 14) return 6;
    if (score == 15) return 8;
    if (score == 16) return 10;
    if (score == 17) return 13;
    if (score == 18) return 16;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('Points used: $_totalCost / 25',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _stats.length,
            itemBuilder: (ctx, i) {
              final stat = _stats[i];
              return ListTile(
                title: Text(stat.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: stat.score > 8
                          ? () => setState(() => stat.score--)
                          : null,
                    ),
                    Text('${stat.score}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: stat.score < 18
                          ? () => setState(() => stat.score++)
                          : null,
                    ),
                    SizedBox(
                      width: 50,
                      child: Text('Cost: ${_costForScore(stat.score)}',
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatEntry {
  final String name;
  int score;
  _StatEntry(this.name, this.score);
}
