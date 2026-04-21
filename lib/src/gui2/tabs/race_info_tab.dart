// Translation of pcgen.gui2.tabs.RaceInfoTab

import 'package:flutter/material.dart';

/// Tab panel for selecting and viewing race information.
class RaceInfoTab extends StatefulWidget {
  const RaceInfoTab({super.key});

  @override
  State<RaceInfoTab> createState() => RaceInfoTabState();
}

class RaceInfoTabState extends State<RaceInfoTab> {
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
                child: Text('Available Races',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView(children: const [
                  ListTile(title: Text('Human')),
                  ListTile(title: Text('Elf')),
                  ListTile(title: Text('Dwarf')),
                  ListTile(title: Text('Halfling')),
                ]),
              ),
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
                child: Text('Race Info', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Expanded(child: Center(child: Text('Select a race to see info'))),
            ],
          ),
        ),
      ],
    );
  }
}
