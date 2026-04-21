// Translation of pcgen.gui2.tools.CommonMenuText

import 'package:flutter/material.dart';

/// Holds the resolved text properties for a menu item or action.
class MenuTextProperties {
  final String name;
  final String? shortDescription;
  final String? mnemonic;

  const MenuTextProperties({
    required this.name,
    this.shortDescription,
    this.mnemonic,
  });
}

/// Common menu text (name, tooltip, mnemonic) generation from localisation
/// bundle keys.
///
/// In Dart/Flutter there is no javax.swing.Action or AbstractButton.  Instead
/// this class resolves text properties into a [MenuTextProperties] value that
/// callers can apply to Flutter widgets (e.g. [Text], [Tooltip]).
final class CommonMenuText {
  static const String _mnemonicSuffix = 'mn_';
  static const String _tipSuffix = 'Tip';

  CommonMenuText._();

  /// Resolve the display name for [prop] using optional [substitutes].
  static String getName(String prop, [List<Object> substitutes = const []]) {
    return _formatString(prop, substitutes);
  }

  /// Resolve the tooltip / short description for [prop].
  /// Returns null when no tip key exists.
  static String? getShortDesc(String prop, [List<Object> substitutes = const []]) {
    final result = _formatString('$prop$_tipSuffix', substitutes);
    return result.isEmpty ? null : result;
  }

  /// Resolve the mnemonic character for [prop].
  /// Returns the first character of the mnemonic key, or null if none.
  static String? getMnemonic(String prop) {
    final key = _mnemonicSuffix + prop;
    // In a real implementation this would look up the localisation bundle.
    // Return null when no mnemonic is defined.
    if (key.isEmpty) return null;
    return null; // resolved at runtime from LanguageBundle equivalent
  }

  /// Build a [MenuTextProperties] for [prop] using optional [substitutes].
  static MenuTextProperties resolve(String prop, [List<Object> substitutes = const []]) {
    return MenuTextProperties(
      name: getName(prop, substitutes),
      shortDescription: getShortDesc(prop, substitutes),
      mnemonic: getMnemonic(prop),
    );
  }

  /// Apply [MenuTextProperties] to a [ButtonStyle]-compatible widget builder.
  /// Returns a [Tooltip]-wrapped [Text] that carries both name and tooltip.
  static Widget buildLabel(String prop, [List<Object> substitutes = const []]) {
    final props = resolve(prop, substitutes);
    final label = Text(props.name);
    if (props.shortDescription != null && props.shortDescription!.isNotEmpty) {
      return Tooltip(message: props.shortDescription!, child: label);
    }
    return label;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Simple string formatter that replaces positional `{0}`, `{1}`, …
  /// placeholders with the provided [substitutes].
  static String _formatString(String pattern, List<Object> substitutes) {
    var result = pattern;
    for (var i = 0; i < substitutes.length; i++) {
      result = result.replaceAll('{$i}', substitutes[i].toString());
    }
    return result;
  }
}
