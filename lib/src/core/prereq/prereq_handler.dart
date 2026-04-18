import '../../cdom/prereq/prerequisite.dart';

/// Tests if a character passes the prerequisites for a given caller.
///
/// Translated from pcgen.core.prereq.PrereqHandler (first 80 lines +
/// additional inferred structure).
final class PrereqHandler {
  PrereqHandler._(); // Prevent instantiation

  /// Test if the character passes the prerequisites for the caller.
  ///
  /// The caller is used to check if prereqs can be bypassed (e.g., via
  /// QUALIFY statements in templates or FEATPRE rules).
  ///
  /// [prereqList] The list of prerequisites to be tested.
  /// [aPC] The character to be checked (dynamic to avoid circular import).
  /// [caller] The object that we are testing qualification for.
  ///
  /// Returns true if the character passes all prereqs.
  static bool passesAll(
    List<Prerequisite>? prereqList,
    dynamic aPC,
    Object? caller,
  ) {
    if (prereqList == null || prereqList.isEmpty) return true;

    // Check if the caller is an Ability/Feat and FEATPRE rule is in effect
    // (Globals.checkRule(RuleConstants.FEATPRE)) - deferred to full impl
    // For now, check QUALIFY list on the PC
    if (caller != null && aPC != null) {
      try {
        if ((aPC as dynamic).checkQualifyList(caller) as bool) {
          return true;
        }
      } catch (_) {}
    }

    for (final prereq in prereqList) {
      try {
        if (!(prereq.passes(aPC, caller) as bool)) return false;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  /// Test if the character passes the prerequisites held by [prereqObj].
  ///
  /// [prereqObj] Any object that holds prerequisites (has getPrerequisiteList()).
  /// [caller] The object that we are testing qualification for.
  /// [aPC] The character to be checked.
  static bool passesAllWithObject(
    dynamic prereqObj,
    dynamic caller,
    dynamic aPC,
  ) {
    List<Prerequisite>? prereqList;
    try {
      prereqList = (prereqObj as dynamic).getPrerequisiteList() as List<Prerequisite>?;
    } catch (_) {}
    return passesAll(prereqList, aPC, caller);
  }

  /// Returns an HTML-formatted string describing whether all prereqs pass.
  ///
  /// Used for display in the UI.
  static String toHtmlString(
    List<Prerequisite>? prereqList,
    dynamic aPC,
    Object? caller,
    bool includeHeader,
  ) {
    if (prereqList == null || prereqList.isEmpty) return '';

    final sb = StringBuffer();
    if (includeHeader) sb.write('<html>');

    for (final prereq in prereqList) {
      bool passes = false;
      try {
        passes = prereq.passes(aPC, caller) as bool;
      } catch (_) {}
      final color = passes ? '#000000' : '#FF0000';
      sb.write('<font color="$color">${prereq.getDescription()}</font><br />');
    }

    if (includeHeader) sb.write('</html>');
    return sb.toString();
  }
}
