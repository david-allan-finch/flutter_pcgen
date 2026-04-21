// Translation of pcgen.gui2.converter.panel.ConvertSubPanel

import 'package:flutter/material.dart';

/// Abstract base for converter wizard step panels.
abstract class ConvertSubPanel extends StatefulWidget {
  const ConvertSubPanel({super.key});

  /// Whether this panel's selections are complete and the user can advance.
  bool get isComplete;
}

/// Base state providing common helpers for converter sub-panels.
abstract class ConvertSubPanelState<T extends ConvertSubPanel> extends State<T> {
  void notifyCompletion() => setState(() {});
}
