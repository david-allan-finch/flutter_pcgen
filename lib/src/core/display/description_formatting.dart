// Copyright (c) Tom Parker, 2008.
//
// Translation of pcgen.core.display.DescriptionFormatting

/// Utilities for formatting description text, optionally wrapping PI content
/// in HTML bold/italic tags.
class DescriptionFormatting {
  DescriptionFormatting._();

  /// Wraps [desc] in `<b><i>…</i></b>` if the object's DESC_PI flag is set
  /// and [desc] is non-empty. Adds `<html>…</html>` wrapper when [useHeader]
  /// is true.
  static String piWrapDesc(dynamic cdo, String desc, bool useHeader) {
    final descPi = cdo.getSafeObject(CDOMObjectKey.getConstant('DESC_PI')) as bool? ?? false;
    if (descPi && desc.isNotEmpty) {
      final buf = StringBuffer();
      if (useHeader) buf.write('<html>');
      buf.write('<b><i>');
      buf.write(desc);
      buf.write('</i></b>');
      if (useHeader) buf.write('</html>');
      return buf.toString();
    }
    return desc;
  }
}
