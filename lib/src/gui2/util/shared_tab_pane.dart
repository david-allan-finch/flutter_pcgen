//
// Copyright 2009 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
