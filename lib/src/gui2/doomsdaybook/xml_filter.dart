// Translation of pcgen.gui2.doomsdaybook.XMLFilter

/// File extension filter for XML files.
class XmlFilter {
  static const List<String> extensions = ['xml', 'XML'];

  static bool accept(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.xml');
  }

  String getDescription() => 'XML Files (*.xml)';
}
