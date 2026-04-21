// Translation of pcgen.gui2.util.SharedTabPane

import 'package:flutter/material.dart';

/// A tab pane that shares a single child widget across all tabs.
/// When the selected tab changes the shared component is re-parented into
/// the newly selected tab's slot.
class SharedTabPane extends StatefulWidget {
  final List<String> tabTitles;
  final Widget? sharedComponent;

  const SharedTabPane({
    super.key,
    required this.tabTitles,
    this.sharedComponent,
  });

  @override
  State<SharedTabPane> createState() => SharedTabPaneState();
}

class SharedTabPaneState extends State<SharedTabPane>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabTitles.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: widget.tabTitles.map((t) => Tab(text: t)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabTitles
                .map((_) => widget.sharedComponent ?? const SizedBox.shrink())
                .toList(),
          ),
        ),
      ],
    );
  }
}
