// Translation of pcgen.gui3.preferences.LevelUpPreferencesModel

import 'package:flutter/foundation.dart';

/// Model for the Level Up preferences panel.
class LevelUpPreferencesModel extends ChangeNotifier {
  String _hpRollMethod = 'Standard';
  int _hpPercentage = 100;
  bool _askForHPMethod = true;
  bool _showInfoOnLevelUp = true;

  static const List<String> hpRollMethods = [
    'Standard', 'Auto Max', 'Percentage', 'Average',
  ];

  String get hpRollMethod => _hpRollMethod;
  int get hpPercentage => _hpPercentage;
  bool get askForHPMethod => _askForHPMethod;
  bool get showInfoOnLevelUp => _showInfoOnLevelUp;

  void setHpRollMethod(String v) { _hpRollMethod = v; notifyListeners(); }
  void setHpPercentage(int v) { _hpPercentage = v.clamp(1, 100); notifyListeners(); }
  void setAskForHPMethod(bool v) { _askForHPMethod = v; notifyListeners(); }
  void setShowInfoOnLevelUp(bool v) { _showInfoOnLevelUp = v; notifyListeners(); }
}
