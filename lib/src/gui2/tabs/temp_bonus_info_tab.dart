// Translation of pcgen.gui2.tabs.TempBonusInfoTab

import 'package:flutter/material.dart';

/// Tab panel for viewing and applying temporary bonuses.
class TempBonusInfoTab extends StatefulWidget {
  const TempBonusInfoTab({super.key});

  @override
  State<TempBonusInfoTab> createState() => TempBonusInfoTabState();
}

class TempBonusInfoTabState extends State<TempBonusInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Available Temp Bonuses',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(child: ListView(children: const [])),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Active Temp Bonuses',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(child: ListView(children: const [])),
            ],
          ),
        ),
      ],
    );
  }
}
