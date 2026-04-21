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
// Translation of pcgen.gui2.tabs.models.HtmlSheetSupport

/// Utilities for rendering character data as HTML for the character sheet view.
class HtmlSheetSupport {
  HtmlSheetSupport._();

  /// Build a simple HTML table from a list of rows.
  static String buildTable(List<String> headers, List<List<String>> rows) {
    final buf = StringBuffer('<table border="1" cellpadding="2" cellspacing="0">');
    buf.write('<tr>');
    for (final h in headers) {
      buf.write('<th>$h</th>');
    }
    buf.write('</tr>');
    for (final row in rows) {
      buf.write('<tr>');
      for (final cell in row) {
        buf.write('<td>$cell</td>');
      }
      buf.write('</tr>');
    }
    buf.write('</table>');
    return buf.toString();
  }

  /// Wrap content in a basic HTML document.
  static String wrapHtml(String body, {String title = 'Character Sheet'}) {
    return '''<!DOCTYPE html>
<html>
<head><title>$title</title>
<style>body { font-family: sans-serif; font-size: 12px; }</style>
</head>
<body>$body</body>
</html>''';
  }

  static String escape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }
}
