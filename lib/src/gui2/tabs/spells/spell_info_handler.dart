//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.spells.SpellInfoHandler

import 'package:flutter/foundation.dart';

/// Handles display of detailed info for a selected spell node.
class SpellInfoHandler extends ChangeNotifier {
  Map<String, dynamic>? _selectedSpell;

  Map<String, dynamic>? get selectedSpell => _selectedSpell;

  void setSelectedSpell(Map<String, dynamic>? spell) {
    _selectedSpell = spell;
    notifyListeners();
  }

  /// Returns HTML-formatted description of the selected spell.
  String buildInfoHtml() {
    final spell = _selectedSpell;
    if (spell == null) return '<p>No spell selected</p>';
    final buf = StringBuffer('<html><body>');
    buf.write('<h3>${_esc(spell['name'] ?? '')}</h3>');
    _row(buf, 'School', spell['school']);
    _row(buf, 'Components', spell['components']);
    _row(buf, 'Cast Time', spell['castTime']);
    _row(buf, 'Range', spell['range']);
    _row(buf, 'Target/Area', spell['target']);
    _row(buf, 'Duration', spell['duration']);
    _row(buf, 'Save', spell['save']);
    _row(buf, 'SR', spell['sr']);
    if (spell['description'] != null) {
      buf.write('<p>${_esc(spell['description'] as String)}</p>');
    }
    buf.write('</body></html>');
    return buf.toString();
  }

  void _row(StringBuffer buf, String label, dynamic value) {
    if (value == null) return;
    buf.write('<b>$label:</b> ${_esc(value.toString())}<br>');
  }

  String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
