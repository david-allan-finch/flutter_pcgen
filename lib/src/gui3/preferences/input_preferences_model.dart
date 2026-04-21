// Translation of pcgen.gui3.preferences.InputPreferencesModel

import 'package:flutter/foundation.dart';

/// Model for the Input preferences panel.
class InputPreferencesModel extends ChangeNotifier {
  bool _allowNegativeHP = false;
  bool _allowDebt = false;
  bool _showOutputNameInsteadOfName = false;
  int _maxLevelIncrease = 5;
  bool _useHighestStatToBuyDown = false;

  bool get allowNegativeHP => _allowNegativeHP;
  bool get allowDebt => _allowDebt;
  bool get showOutputNameInsteadOfName => _showOutputNameInsteadOfName;
  int get maxLevelIncrease => _maxLevelIncrease;
  bool get useHighestStatToBuyDown => _useHighestStatToBuyDown;

  void setAllowNegativeHP(bool v) { _allowNegativeHP = v; notifyListeners(); }
  void setAllowDebt(bool v) { _allowDebt = v; notifyListeners(); }
  void setShowOutputNameInsteadOfName(bool v) { _showOutputNameInsteadOfName = v; notifyListeners(); }
  void setMaxLevelIncrease(int v) { _maxLevelIncrease = v; notifyListeners(); }
  void setUseHighestStatToBuyDown(bool v) { _useHighestStatToBuyDown = v; notifyListeners(); }
}
