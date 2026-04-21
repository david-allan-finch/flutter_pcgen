// *
// DescriptionInfoTab.java Copyright James Dempsey, 2010
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
