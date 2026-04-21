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
