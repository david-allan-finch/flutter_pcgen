//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
