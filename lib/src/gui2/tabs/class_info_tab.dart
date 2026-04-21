// Translation of pcgen.gui2.tabs.ClassInfoTab

import 'package:flutter/material.dart';

/// Tab panel for viewing and adding character classes.
class ClassInfoTab extends StatefulWidget {
  const ClassInfoTab({super.key});

  @override
  State<ClassInfoTab> createState() => ClassInfoTabState();
}

class ClassInfoTabState extends State<ClassInfoTab> {
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
                child: Text('Available Classes',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView(children: const [
                  ListTile(title: Text('Fighter')),
                  ListTile(title: Text('Wizard')),
                  ListTile(title: Text('Rogue')),
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
                child: Text('Class Info', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Expanded(child: Center(child: Text('Select a class to see info'))),
            ],
          ),
        ),
      ],
    );
  }
}
