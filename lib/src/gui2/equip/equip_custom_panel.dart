// Translation of pcgen.gui2.equip.EquipCustomPanel

import 'package:flutter/material.dart';

/// Panel for customizing equipment items (adding/removing modifiers).
class EquipCustomPanel extends StatefulWidget {
  final dynamic equipment;
  final dynamic character;

  const EquipCustomPanel({
    super.key,
    required this.equipment,
    required this.character,
  });

  @override
  State<EquipCustomPanel> createState() => _EquipCustomPanelState();
}

class _EquipCustomPanelState extends State<EquipCustomPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Equipment Customization',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const Expanded(
          child: Center(child: Text('Modifier selection')),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('OK'),
            ),
          ],
        ),
      ],
    );
  }
}
