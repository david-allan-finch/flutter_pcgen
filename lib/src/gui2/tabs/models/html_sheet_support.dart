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
