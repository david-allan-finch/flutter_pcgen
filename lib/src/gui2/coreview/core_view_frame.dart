//
// Copyright (c) Thomas Parker, 2013-14.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.gui2.coreview.CoreViewFrame

import 'package:flutter/material.dart';

/// Window for viewing core data (variables, facts, etc.) on a character.
class CoreViewFrame extends StatefulWidget {
  final dynamic character;

  const CoreViewFrame({super.key, required this.character});

  @override
  State<CoreViewFrame> createState() => _CoreViewFrameState();
}

class _CoreViewFrameState extends State<CoreViewFrame> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Core View - ${widget.character?.getNameRef()?.get() ?? "Character"}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search variables...',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const Expanded(
            child: Center(child: Text('Variable and fact browser')),
          ),
        ],
      ),
    );
  }
}
