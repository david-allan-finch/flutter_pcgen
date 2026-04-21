// Translation of pcgen.gui2.solverview.ObjectNameDisplayer

/// Provides a display name for an object in the solver view.
class ObjectNameDisplayer {
  static String getDisplayName(dynamic obj) {
    if (obj == null) return '(null)';
    try {
      final name = obj.getKeyName?.call();
      if (name != null) return name.toString();
    } catch (_) {}
    try {
      final name = obj.getDisplayName?.call();
      if (name != null) return name.toString();
    } catch (_) {}
    return obj.toString();
  }
}
