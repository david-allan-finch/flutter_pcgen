//
// Copyright 2002 (C) Chris Ryan
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
// Translation of pcgen.gui2.prefs.PurchaseModeFrame

import 'package:flutter/material.dart';

/// Dialog/frame for configuring point-buy purchase mode settings.
class PurchaseModeFrame extends StatefulWidget {
  const PurchaseModeFrame({super.key});

  @override
  State<PurchaseModeFrame> createState() => _PurchaseModeFrameState();
}

class _PurchaseModeFrameState extends State<PurchaseModeFrame> {
  final List<_CostEntry> _costs = List.generate(
    11,
    (i) => _CostEntry(score: i + 8, cost: i),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Mode')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Score')),
                  DataColumn(label: Text('Cost')),
                ],
                rows: _costs
                    .map((entry) => DataRow(cells: [
                          DataCell(Text(entry.score.toString())),
                          DataCell(Text(entry.cost.toString())),
                        ]))
                    .toList(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostEntry {
  int score;
  int cost;
  _CostEntry({required this.score, required this.cost});
}
