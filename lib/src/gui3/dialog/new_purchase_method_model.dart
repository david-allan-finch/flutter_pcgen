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
