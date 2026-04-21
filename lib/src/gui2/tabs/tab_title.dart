//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.TabTitle

import 'package:flutter/foundation.dart';

/// A container for information relating to how a character tab should be displayed.
class TabTitle extends ChangeNotifier {
  static const String title = 'title';
  static const String icon = 'icon';
  static const String tooltip = 'tooltip';
  static const String tab = 'tab';

  final Map<String, dynamic> _propertyTable = {};

  TabTitle();

  TabTitle.fromTab(dynamic tabEnum) {
    final label = tabEnum?.label as String?;
    if (label != null) {
      if (label.startsWith('in_')) {
        putValue(title, label); // Would look up bundle string in full impl
      } else {
        putValue(title, label);
      }
      putValue(tab, tabEnum);
    }
  }

  TabTitle.withTitle(String titleStr, dynamic tabEnum) {
    if (titleStr.startsWith('in_')) {
      putValue(title, titleStr); // Would look up bundle string in full impl
    } else {
      putValue(title, titleStr);
    }
    if (tabEnum != null) {
      putValue(tab, tabEnum);
    }
  }

  dynamic getValue(String prop) => _propertyTable[prop];

  void putValue(String prop, dynamic value) {
    _propertyTable[prop] = value;
    notifyListeners();
  }

  dynamic getTab() => getValue(tab);
}
