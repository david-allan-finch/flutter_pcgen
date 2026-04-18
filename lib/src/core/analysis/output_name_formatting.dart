/// Utility class for formatting output names of CDOMObjects.
///
/// Translated from pcgen.core.analysis.OutputNameFormatting.
final class OutputNameFormatting {
  OutputNameFormatting._(); // Prevent instantiation

  /// Parse the output name of [po] to substitute variable references.
  ///
  /// [po] is a dynamic reference to a CDOMObject.
  /// [aPC] is a dynamic reference to PlayerCharacter.
  static String parseOutputName(dynamic po, dynamic aPC) {
    return _parseOutputNameString(getOutputName(po), aPC);
  }

  /// Parse an output name string, substituting %N placeholders with
  /// variable values from [aPC].
  ///
  /// The format is: "prefix with %placeholders|VAR1|VAR2|..."
  static String _parseOutputNameString(String aString, dynamic aPC) {
    final varIndex = aString.indexOf('|');
    if (varIndex <= 0) return aString;

    final parts = aString.split('|');
    final preVarStr = parts[0];

    final varArray = <double>[];
    final tokenList = <String>[];

    for (int i = 1; i < parts.length; i++) {
      final token = parts[i];
      tokenList.add(token.toUpperCase());
      double val = 0.0;
      try {
        val = (aPC as dynamic).getVariableValue(token, '') as double;
      } catch (_) {}
      varArray.add(val);
    }

    final result = StringBuffer();
    int varCount = 0;
    int subIndex = preVarStr.indexOf('%');
    int lastIndex = 0;

    while (subIndex >= 0) {
      if (subIndex > 0) {
        result.write(preVarStr.substring(lastIndex, subIndex));
      }

      if (varCount < tokenList.length) {
        final token = tokenList[varCount];
        final val = varArray[varCount];

        if (token.endsWith('.INTVAL')) {
          result.write(val.truncate().toString());
        } else {
          result.write(val.toString());
        }
        varCount++;
      }

      lastIndex = subIndex + 1;
      subIndex = preVarStr.indexOf('%', lastIndex);
    }

    if (preVarStr.length > lastIndex) {
      result.write(preVarStr.substring(lastIndex));
    }

    return result.toString();
  }

  /// Returns the product identity formatted string for the object.
  ///
  /// If the object has NAME_PI set, wraps the name in bold-italic HTML.
  static String piString(dynamic po) {
    String aString = po.toString() as String;

    // Check if we should use output name for equipment
    try {
      aString = getOutputName(po);
    } catch (_) {}

    bool isPI = false;
    try {
      isPI = (po as dynamic).getSafe('NAME_PI') as bool? ?? false;
    } catch (_) {}

    if (isPI) {
      return '<b><i>$aString</i></b>';
    }
    return aString;
  }

  /// Rephrase parenthetical name components.
  ///
  /// Reverses the order of slash-separated components within parentheses.
  /// e.g., "Sword (Bastard/Exotic)" → "Exotic Bastard"
  static String _getPreFormattedOutputName(String displayName) {
    if (!displayName.contains('(') || !displayName.contains(')')) {
      return displayName;
    }

    final openIdx = displayName.indexOf('(');
    final closeIdx = displayName.lastIndexOf(')');
    final subName = displayName.substring(openIdx + 1, closeIdx);
    final parts = subName.split('/');
    final newNameBuff = StringBuffer();

    for (int i = parts.length - 1; i >= 0; i--) {
      if (newNameBuff.isNotEmpty) newNameBuff.write(' ');
      newNameBuff.write(parts[i]);
    }

    return newNameBuff.toString();
  }

  /// Get the output name of a CDOMObject.
  ///
  /// Handles the [BASE] and [NAME] substitutions.
  /// [po] is a dynamic reference to a CDOMObject.
  static String getOutputName(dynamic po) {
    String? outputName;
    String displayName = '';

    try {
      outputName = (po as dynamic).get('OUTPUT_NAME') as String?;
    } catch (_) {}

    try {
      displayName = (po as dynamic).getDisplayName() as String;
    } catch (_) {
      displayName = po.toString() as String;
    }

    if (outputName == null) {
      return displayName;
    }

    if (outputName.toLowerCase() == '[base]' && displayName.contains('(')) {
      outputName = displayName.substring(0, displayName.indexOf('(')).trim();
    }

    if (outputName.contains('[NAME]')) {
      final preFormatted = _getPreFormattedOutputName(displayName);
      outputName = outputName.replaceAll('[NAME]', preFormatted);
    }

    return outputName;
  }
}
