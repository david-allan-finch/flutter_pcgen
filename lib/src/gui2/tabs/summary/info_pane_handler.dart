// Translation of pcgen.gui2.tabs.summary.InfoPaneHandler

import 'package:flutter/foundation.dart';

/// Manages the HTML info pane content for a selected item on the Summary tab.
class InfoPaneHandler extends ChangeNotifier {
  String _htmlContent = '';

  String get htmlContent => _htmlContent;

  void setContent(String html) {
    _htmlContent = html;
    notifyListeners();
  }

  void clear() {
    _htmlContent = '';
    notifyListeners();
  }

  /// Build info HTML for a character overview.
  void showCharacterInfo(dynamic character) {
    if (character == null) {
      setContent('<p>No character loaded</p>');
      return;
    }
    final buf = StringBuffer('<html><body>');
    buf.write('<h3>${_esc(character['name']?.toString() ?? 'Unknown')}</h3>');
    final race = character['race'];
    if (race != null) buf.write('<b>Race:</b> ${_esc(race.toString())}<br>');
    final classes = character['classes'];
    if (classes != null) buf.write('<b>Classes:</b> ${_esc(classes.toString())}<br>');
    final alignment = character['alignment'];
    if (alignment != null) buf.write('<b>Alignment:</b> ${_esc(alignment.toString())}<br>');
    buf.write('</body></html>');
    setContent(buf.toString());
  }

  String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
