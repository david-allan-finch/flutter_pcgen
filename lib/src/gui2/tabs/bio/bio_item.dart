//
// Copyright (c) 2019 Tom Parker <thpr@users.sourceforge.net>
// extracted from BiographyInfoPane.java
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.bio.BioItem

import 'package:flutter/material.dart';

/// A single biography field row: label + editable text field.
class BioItem extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String>? onChanged;

  const BioItem({
    super.key,
    required this.label,
    this.initialValue = '',
    this.onChanged,
  });

  @override
  State<BioItem> createState() => _BioItemState();
}

class _BioItemState extends State<BioItem> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(widget.label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
