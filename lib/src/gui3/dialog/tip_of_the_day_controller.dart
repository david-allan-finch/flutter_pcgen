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
