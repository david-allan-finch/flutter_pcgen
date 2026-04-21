// Translation of pcgen.gui3.dialog.DebugDialog

import 'package:flutter/material.dart';
import 'debug_dialog_controller.dart';

/// Debug/log viewer dialog showing PCGen log output.
class DebugDialog extends StatelessWidget {
  final DebugDialogController controller;

  const DebugDialog({super.key, required this.controller});

  static Future<void> show(BuildContext context, DebugDialogController controller) {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: SizedBox(
          width: 700,
          height: 500,
          child: DebugDialog(controller: controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Debug Log'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Filter...',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.setFilter,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: controller.clear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: controller,
            builder: (ctx, _) => ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: controller.logLines.length,
              itemBuilder: (c, i) => Text(
                controller.logLines[i],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
