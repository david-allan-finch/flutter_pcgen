// Translation of pcgen.gui2.dialog.AbstractDialog

import 'package:flutter/material.dart';

/// Base class for PCGen dialogs.
abstract class AbstractDialog extends StatefulWidget {
  const AbstractDialog({super.key});

  /// Shows this dialog and returns when it is closed.
  Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => this,
    );
  }
}

abstract class AbstractDialogState<T extends AbstractDialog> extends State<T> {
  void closeDialog() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) => buildDialog(context);

  Widget buildDialog(BuildContext context);
}
