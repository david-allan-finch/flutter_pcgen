// Translation of pcgen.gui2.tabs.DescriptionInfoTab

import 'package:flutter/material.dart';

/// Tab panel for character description (biography, portrait, notes).
class DescriptionInfoTab extends StatefulWidget {
  const DescriptionInfoTab({super.key});

  @override
  State<DescriptionInfoTab> createState() => DescriptionInfoTabState();
}

class DescriptionInfoTabState extends State<DescriptionInfoTab>
    with SingleTickerProviderStateMixin {
  dynamic _character;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            Tab(text: 'Biography'),
            Tab(text: 'Portrait'),
            Tab(text: 'Notes'),
            Tab(text: 'Campaign History'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              Center(child: Text('Biography')),
              Center(child: Text('Portrait')),
              Center(child: Text('Notes')),
              Center(child: Text('Campaign History')),
            ],
          ),
        ),
      ],
    );
  }
}
