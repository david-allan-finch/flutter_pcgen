// Translation of pcgen.gui2.tabs.SkillInfoTab

import 'package:flutter/material.dart';

/// Tab panel for viewing and assigning skill ranks.
class SkillInfoTab extends StatefulWidget {
  const SkillInfoTab({super.key});

  @override
  State<SkillInfoTab> createState() => SkillInfoTabState();
}

class SkillInfoTabState extends State<SkillInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Text('Skill Points Remaining: '),
              Text('${_getRemainingPoints()}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Skill')),
                DataColumn(label: Text('Ranks')),
                DataColumn(label: Text('Modifier')),
                DataColumn(label: Text('Total')),
              ],
              rows: const [],
            ),
          ),
        ),
      ],
    );
  }

  int _getRemainingPoints() {
    try { return _character?.getSkillPool() as int? ?? 0; }
    catch (_) { return 0; }
  }
}
