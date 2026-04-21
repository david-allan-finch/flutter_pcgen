// Translation of pcgen.gui2.tabs.EquipInfoTab

import 'package:flutter/material.dart';

/// Tab panel for the equipment/gear tab.
class EquipInfoTab extends StatefulWidget {
  const EquipInfoTab({super.key});

  @override
  State<EquipInfoTab> createState() => EquipInfoTabState();
}

class EquipInfoTabState extends State<EquipInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Available Equipment',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(child: ListView(children: const [])),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Equipped',
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
