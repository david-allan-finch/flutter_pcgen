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
