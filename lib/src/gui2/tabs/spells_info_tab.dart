// Translation of pcgen.gui2.tabs.SpellsInfoTab

import 'package:flutter/material.dart';

/// Tab panel for managing spells (known, prepared, spell books).
class SpellsInfoTab extends StatefulWidget {
  const SpellsInfoTab({super.key});

  @override
  State<SpellsInfoTab> createState() => SpellsInfoTabState();
}

class SpellsInfoTabState extends State<SpellsInfoTab>
    with SingleTickerProviderStateMixin {
  dynamic _character;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Known'),
            Tab(text: 'Prepared'),
            Tab(text: 'Spell Books'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              Center(child: Text('Known spells')),
              Center(child: Text('Prepared spells')),
              Center(child: Text('Spell books')),
            ],
          ),
        ),
      ],
    );
  }
}
