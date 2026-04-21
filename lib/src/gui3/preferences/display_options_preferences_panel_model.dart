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
