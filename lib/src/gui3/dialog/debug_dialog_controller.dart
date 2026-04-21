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
// Translation of pcgen.gui3.dialog.DebugDialogController

import 'package:flutter/foundation.dart';

/// Controller for the debug/log dialog — collects and exposes log messages.
class DebugDialogController extends ChangeNotifier {
  final List<String> _logLines = [];
  String _filter = '';

  List<String> get logLines {
    if (_filter.isEmpty) return List.unmodifiable(_logLines);
    return _logLines.where((l) => l.contains(_filter)).toList();
  }

  String get filter => _filter;

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void addLine(String line) {
    _logLines.add(line);
    notifyListeners();
  }

  void clear() {
    _logLines.clear();
    notifyListeners();
  }
}
