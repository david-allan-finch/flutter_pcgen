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
