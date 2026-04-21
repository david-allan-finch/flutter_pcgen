// Translation of pcgen.gui2.tabs.AbilitiesInfoTab

import 'package:flutter/material.dart';
import 'models/character_combo_box_model.dart';
import '../filter/filter_bar.dart';

/// Tab panel for viewing and selecting character abilities/feats.
class AbilitiesInfoTab extends StatefulWidget {
  const AbilitiesInfoTab({super.key});

  @override
  State<AbilitiesInfoTab> createState() => AbilitiesInfoTabState();
}

class AbilitiesInfoTabState extends State<AbilitiesInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) {
    setState(() => _character = character);
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) {
      return const Center(child: Text('No character loaded'));
    }
    return Column(
      children: [
        FilterBar(onFilterChanged: (_) {}),
        Expanded(
          child: Row(
            children: [
              // Available abilities panel
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Available',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView(
                        children: const [
                          ListTile(title: Text('Load a source to see abilities')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(),
              // Selected abilities panel
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Selected',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView(children: const []),
                    ),
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
