// Translation of pcgen.gui3.dialog.TipOfTheDayController

import 'package:flutter/foundation.dart';

/// Controller for the Tip of the Day dialog.
class TipOfTheDayController extends ChangeNotifier {
  final List<String> _tips;
  int _currentIndex = 0;
  bool _showOnStartup;

  TipOfTheDayController({
    required List<String> tips,
    bool showOnStartup = true,
  })  : _tips = tips,
        _showOnStartup = showOnStartup;

  String get currentTip =>
      _tips.isNotEmpty ? _tips[_currentIndex] : 'No tips available.';

  bool get showOnStartup => _showOnStartup;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _tips.length - 1;
  int get tipNumber => _currentIndex + 1;
  int get totalTips => _tips.length;

  void nextTip() {
    if (hasNext) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousTip() {
    if (hasPrevious) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void setShowOnStartup(bool value) {
    _showOnStartup = value;
    notifyListeners();
  }
}
