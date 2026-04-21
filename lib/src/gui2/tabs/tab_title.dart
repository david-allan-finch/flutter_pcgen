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
