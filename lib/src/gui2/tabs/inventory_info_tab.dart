// Translation of pcgen.gui2.tabs.InventoryInfoTab

import 'package:flutter/material.dart';
import 'equip_info_tab.dart';

/// Tab panel for the inventory/gear management tab (wraps equipment sub-tabs).
class InventoryInfoTab extends StatefulWidget {
  const InventoryInfoTab({super.key});

  @override
  State<InventoryInfoTab> createState() => InventoryInfoTabState();
}

class InventoryInfoTabState extends State<InventoryInfoTab>
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
            Tab(text: 'Gear'),
            Tab(text: 'Equipment Sets'),
            Tab(text: 'Purchase'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              EquipInfoTab(key: ValueKey(_character)),
              const Center(child: Text('Equipment sets')),
              const Center(child: Text('Purchase equipment')),
            ],
          ),
        ),
      ],
    );
  }
}
