// Translation of pcgen.gui3.component.OKCloseButtonBar

import 'package:flutter/material.dart';

/// A standard button bar with OK and Close/Cancel buttons,
/// used at the bottom of preference and dialog panels.
class OKCloseButtonBar extends StatelessWidget {
  final VoidCallback? onOk;
  final VoidCallback? onClose;
  final String okLabel;
  final String closeLabel;

  const OKCloseButtonBar({
    super.key,
    this.onOk,
    this.onClose,
    this.okLabel = 'OK',
    this.closeLabel = 'Close',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onOk != null) ...[
            ElevatedButton(onPressed: onOk, child: Text(okLabel)),
            const SizedBox(width: 8),
          ],
          OutlinedButton(
            onPressed: onClose ?? () => Navigator.of(context).maybePop(),
            child: Text(closeLabel),
          ),
        ],
      ),
    );
  }
}
