// Translation of pcgen.gui3.dialog.DebugDialogController

import 'package:flutter/foundation.dart';

/// Controller for the debug/log dialog — collects and exposes log messages.
class DebugDialogController extends ChangeNotifier {
  final List<String> _logLines = [];
  String _filter = '';

  List<String> get logLines {
    if (_filter.isEmpty) return List.unmodifiable(_logLines);
    return _logLines.where((l) => l.contains(_filter)).toList();
  }

  String get filter => _filter;

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void addLine(String line) {
    _logLines.add(line);
    notifyListeners();
  }

  void clear() {
    _logLines.clear();
    notifyListeners();
  }
}
