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
// Translation of pcgen.gui2.tabs.summary.InfoPaneHandler

import 'package:flutter/foundation.dart';

/// Manages the HTML info pane content for a selected item on the Summary tab.
class InfoPaneHandler extends ChangeNotifier {
  // ignore: unused_field
  final dynamic _character;

  InfoPaneHandler([this._character]);

  /// Called when this handler is attached to the visible tab.
  void install() {}

  /// Called when this handler is detached from the visible tab.
  void uninstall() {}

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
