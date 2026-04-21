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
