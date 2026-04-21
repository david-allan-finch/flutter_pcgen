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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui3.preferences.PCGenPreferencesModel

import 'package:flutter/foundation.dart';

/// Top-level model for all PCGen preferences, composed of sub-models.
class PCGenPreferencesModel extends ChangeNotifier {
  final Map<String, dynamic> _prefs = {};

  T get<T>(String key, T defaultValue) {
    final v = _prefs[key];
    return v is T ? v : defaultValue;
  }

  void set<T>(String key, T value) {
    if (_prefs[key] == value) return;
    _prefs[key] = value;
    notifyListeners();
  }

  Map<String, dynamic> toMap() => Map.unmodifiable(_prefs);

  void loadFrom(Map<String, dynamic> prefs) {
    _prefs.addAll(prefs);
    notifyListeners();
  }

  void reset() {
    _prefs.clear();
    notifyListeners();
  }
}
