// Translation of pcgen.gui2.sources.SourceSelectionDialog

import 'package:flutter/material.dart';

/// Dialog for selecting game sources (books/settings) to load.
class SourceSelectionDialog extends StatefulWidget {
  final dynamic uiContext;

  const SourceSelectionDialog({super.key, required this.uiContext});

  static bool skipSourceSelection() => false;

  @override
  State<SourceSelectionDialog> createState() => _SourceSelectionDialogState();
}

class _SourceSelectionDialogState extends State<SourceSelectionDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Source Selection'),
      content: SizedBox(
        width: 700,
        height: 500,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Basic'), Tab(text: 'Advanced')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  Center(child: Text('Basic source selection')),
                  Center(child: Text('Advanced source selection')),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Load'),
        ),
      ],
    );
  }
}
