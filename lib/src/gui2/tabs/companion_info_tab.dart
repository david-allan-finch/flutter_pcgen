// Translation of pcgen.gui2.tabs.CompanionInfoTab

import 'package:flutter/material.dart';

/// Tab panel for managing character companions (animal companion, familiar, etc.).
class CompanionInfoTab extends StatefulWidget {
  const CompanionInfoTab({super.key});

  @override
  State<CompanionInfoTab> createState() => CompanionInfoTabState();
}

class CompanionInfoTabState extends State<CompanionInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Companions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Expanded(
          child: ListView(
            children: const [
              ListTile(title: Text('No companions')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Companion'),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
