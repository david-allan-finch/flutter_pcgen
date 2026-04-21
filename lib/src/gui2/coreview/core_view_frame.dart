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
