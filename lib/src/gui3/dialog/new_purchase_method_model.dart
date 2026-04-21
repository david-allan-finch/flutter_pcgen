// Translation of pcgen.gui3.dialog.NewPurchaseMethodModel

import 'package:flutter/foundation.dart';

/// Model for the New Purchase Method dialog — lets the user define a
/// custom point-buy stat purchase method.
class NewPurchaseMethodModel extends ChangeNotifier {
  String _name = '';
  int _points = 25;

  String get name => _name;
  int get points => _points;

  bool get isValid => _name.trim().isNotEmpty && _points > 0;

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setPoints(int points) {
    _points = points;
    notifyListeners();
  }
}
