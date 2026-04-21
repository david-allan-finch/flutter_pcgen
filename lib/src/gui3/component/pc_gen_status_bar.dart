// Translation of pcgen.gui3.component.PCGenStatusBar (JavaFX version)

import 'package:flutter/material.dart';
import 'pc_gen_status_bar_model.dart';

/// Status bar widget backed by PCGenStatusBarModel.
class PCGenStatusBar extends StatelessWidget {
  final PCGenStatusBarModel model;

  const PCGenStatusBar({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (ctx, _) => Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            if (model.warningMessage != null) ...[
              const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                model.message,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (model.working)
              SizedBox(
                width: 120,
                height: 8,
                child: LinearProgressIndicator(value: model.progress > 0 ? model.progress : null),
              ),
          ],
        ),
      ),
    );
  }
}
