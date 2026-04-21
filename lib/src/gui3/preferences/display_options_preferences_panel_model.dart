// Translation of pcgen.gui3.preferences.DisplayOptionsPreferencesPanelModel

import 'package:flutter/foundation.dart';

/// Model for the Display Options preferences panel.
class DisplayOptionsPreferencesPanelModel extends ChangeNotifier {
  bool _showToolTips = true;
  bool _showMemoryBar = false;
  bool _showImagePreview = true;
  int _fontSize = 12;
  String _looknFeel = 'System';
  bool _collectDiagnostics = false;

  bool get showToolTips => _showToolTips;
  bool get showMemoryBar => _showMemoryBar;
  bool get showImagePreview => _showImagePreview;
  int get fontSize => _fontSize;
  String get looknFeel => _looknFeel;
  bool get collectDiagnostics => _collectDiagnostics;

  void setShowToolTips(bool v) { _showToolTips = v; notifyListeners(); }
  void setShowMemoryBar(bool v) { _showMemoryBar = v; notifyListeners(); }
  void setShowImagePreview(bool v) { _showImagePreview = v; notifyListeners(); }
  void setFontSize(int v) { _fontSize = v; notifyListeners(); }
  void setLooknFeel(String v) { _looknFeel = v; notifyListeners(); }
  void setCollectDiagnostics(bool v) { _collectDiagnostics = v; notifyListeners(); }
}
