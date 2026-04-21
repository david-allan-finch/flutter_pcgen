// Translation of pcgen.gui2.tabs.AbilityChooserTab

import 'package:flutter/material.dart';

/// Tab panel for choosing abilities from the available pool.
class AbilityChooserTab extends StatefulWidget {
  const AbilityChooserTab({super.key});

  @override
  State<AbilityChooserTab> createState() => AbilityChooserTabState();
}

class AbilityChooserTabState extends State<AbilityChooserTab> {
  dynamic _character;
  dynamic _category;

  void setCharacter(dynamic character) => setState(() => _character = character);
  void setCategory(dynamic category) => setState(() => _category = category);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_category != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Category: $_category',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Available'),
                    ),
                    Expanded(child: ListView(children: const [])),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_forward), onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.arrow_back), onPressed: () {}),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Selected'),
                    ),
                    Expanded(child: ListView(children: const [])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
