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
