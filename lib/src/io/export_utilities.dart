// Translation of pcgen.io.ExportUtilities

/// Utility methods for character sheet export.
class ExportUtilities {
  ExportUtilities._();

  /// Returns the appropriate ExportHandler for the given template path.
  static bool isFreeMarkerTemplate(String templatePath) =>
      templatePath.toLowerCase().endsWith('.ftl');

  /// Strips HTML tags from a string for plain-text output.
  static String stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '');
}
