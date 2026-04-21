// Translation of pcgen.gui2.csheet.PreviewVariablesHandler

/// Handles variable substitution for character sheet preview rendering.
class PreviewVariablesHandler {
  final dynamic character;

  PreviewVariablesHandler(this.character);

  /// Replaces variable tokens in [template] with values from the character.
  String processTemplate(String template) {
    String result = template;
    result = result.replaceAll('%NAME%', _getName());
    result = result.replaceAll('%RACE%', _getRace());
    result = result.replaceAll('%CLASS%', _getClass());
    result = result.replaceAll('%LEVEL%', _getLevel().toString());
    return result;
  }

  String _getName() {
    try { return character?.getNameRef()?.get() ?? ''; } catch (_) { return ''; }
  }

  String _getRace() {
    try { return character?.getRace()?.toString() ?? ''; } catch (_) { return ''; }
  }

  String _getClass() {
    try { return character?.getClasses()?.toString() ?? ''; } catch (_) { return ''; }
  }

  int _getLevel() {
    try { return character?.getTotalLevels() as int? ?? 0; } catch (_) { return 0; }
  }
}
