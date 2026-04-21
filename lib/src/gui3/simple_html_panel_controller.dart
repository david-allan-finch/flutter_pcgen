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
// Translation of pcgen.gui3.SimpleHtmlPanelController

import 'package:flutter/foundation.dart';

/// Controller for the SimpleHtmlPanel — manages the HTML content to display.
class SimpleHtmlPanelController extends ChangeNotifier {
  String _html = '';

  String get html => _html;

  void setHtml(String html) {
    if (_html == html) return;
    _html = html;
    notifyListeners();
  }

  void clear() => setHtml('');
}
