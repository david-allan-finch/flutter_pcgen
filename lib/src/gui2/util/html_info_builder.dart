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
