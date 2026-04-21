// Translation of pcgen.gui2.solverview.SolverViewFrame

import 'package:flutter/material.dart';

/// Window for viewing solver results — how variable values are derived.
class SolverViewFrame extends StatefulWidget {
  final dynamic character;

  const SolverViewFrame({super.key, this.character});

  @override
  State<SolverViewFrame> createState() => _SolverViewFrameState();
}

class _SolverViewFrameState extends State<SolverViewFrame> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solver View')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search solver results...',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const Expanded(
            child: Center(child: Text('Solver result browser')),
          ),
        ],
      ),
    );
  }
}
