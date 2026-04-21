//
// Copyright 2007 (C) Koen Van Daele
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
//
// Translation of pcgen.gui2.util.HtmlInfoBuilder

/// Helper class for building HTML info label text used in GUI tabs.
class HtmlInfoBuilder {
  static const String threeSpaces = ' &nbsp; ';

  final StringBuffer _buffer = StringBuffer();
  final bool fullDocument;

  HtmlInfoBuilder({String? title, this.fullDocument = true}) {
    if (fullDocument) _buffer.write('<html>');
    if (title != null) appendTitleElement(title);
  }

  HtmlInfoBuilder append(String string) {
    _buffer.write(string);
    return this;
  }

  HtmlInfoBuilder appendChar(String ch) {
    _buffer.write(ch);
    return this;
  }

  HtmlInfoBuilder appendLineBreak() {
    _buffer.write('<br>');
    return this;
  }

  HtmlInfoBuilder appendSpacer() {
    _buffer.write(threeSpaces);
    return this;
  }

  void appendSmallTitleElement(String title) {
    _buffer.write('<b>$title</b>');
  }

  void appendTitleElement(String title) {
    _buffer.write('<b><font size=+1>$title</font></b>');
  }

  HtmlInfoBuilder appendElement(String key, String value) {
    _buffer.write('<b>$key:</b>&nbsp;$value');
    return this;
  }

  HtmlInfoBuilder appendI18nElement(String propertyKey, String value) {
    return appendElement(propertyKey, value);
  }

  HtmlInfoBuilder appendI18nFormattedElement(String propertyKey,
      List<String> values) {
    _buffer.write(_formatString(propertyKey, values));
    return this;
  }

  void appendIconElement(String iconPath) {
    _buffer.write('<img src="$iconPath" >&nbsp;');
  }

  static String _formatString(String template, List<String> args) {
    String result = template;
    for (int i = 0; i < args.length; i++) {
      result = result.replaceAll('{$i}', args[i]);
    }
    return result;
  }

  @override
  String toString() {
    if (fullDocument) _buffer.write('</html>');
    final result = _buffer.toString();
    if (fullDocument) {
      // remove the closing tag we just added so further calls still work
      final closing = '</html>';
      _buffer.clear();
      _buffer.write(result.substring(0, result.length - closing.length));
    }
    return result;
  }
}
