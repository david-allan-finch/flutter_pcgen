// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractPreEqualConvertPlugin

/// Descriptions of the three strategies for resolving ambiguous PRExxx=value
/// conversion choices.
const String preEqualFlowLeft =
    'Set unspecified values to next identified value '
    '(items queue until set/equals sign flows left)';

const String preEqualFlowRight =
    'Set unspecified values to previous identified value '
    '(equals sign holds on unspecified items until redefined)';

const String preEqualSetOne =
    "Set unspecified values to one (identify as 'present')";

/// Converts old PRExxx token format (e.g. "PRESKILL:3,Spellcraft,Knowledge")
/// into modern FACT-aware form by inserting explicit "=value" suffixes.
///
/// The conversion handles four distinct cases:
///   1. Single item, no "=" → appends "=1".
///   2. Single item, explicit "=" → keeps as-is.
///   3. Multiple items, last has "=" → propagates that value to all items.
///   4. Mixed items (some with "=", some without) → may present three
///      candidate interpretations to a [ConversionDecider] when the
///      interpretations differ.
///
/// TODO: The following Java types have not yet been ported:
///   - TokenProcessEvent (use dynamic for now)
///   - TokenProcessorPlugin interface
///   - ConversionDecider / tpe.getDecider()
///   - CDOMObject (used only as the return type of [getProcessedClass])
///
/// Mirrors Java: AbstractPreEqualConvertPlugin implements TokenProcessorPlugin
abstract class AbstractPreEqualConvertPlugin {
  /// The LST token name this plugin is responsible for (e.g. "PRESKILL").
  ///
  /// Mirrors Java's abstract [getProcessedToken()].
  String getProcessedToken();

  /// Processes the [tpe] (TokenProcessEvent) and rewrites the value so every
  /// item in the comma-separated list has an explicit "=N" suffix.
  ///
  /// Returns null on success; returns an error string if the value is
  /// malformed.
  ///
  /// TODO: parameter type to TokenProcessEvent once ported.
  String? process(dynamic tpe) {
    // TODO: implement once TokenProcessEvent is ported.
    // Java logic (summarised):
    //
    // 1. Split formula into num + rest at the first comma.
    // 2. Validate num is an integer.
    // 3. If rest has no further commas:
    //    a. doPrefix(tpe, num)  — emits "KEY:num,"
    //    b. If no '=' in rest → append rest + "=1"
    //    c. Else              → append rest as-is
    // 4. If rest has multiple items:
    //    Count items with and without '='.
    //    a. Exactly one '=' and it is the last item → propagate its value.
    //    b. Mixed '=' and no-'=' → build three candidate strings (SET_ONE,
    //       FLOW_RIGHT, FLOW_LEFT) and ask the decider to choose if they differ.
    //    c. All have '=' → doPrefix + join as-is.
    //    d. None have '=' → doPrefix + join with "=1," + trailing "=1".
    // 5. tpe.consume() to signal the event was handled.
    throw UnimplementedError(
        'AbstractPreEqualConvertPlugin.process: '
        'requires TokenProcessEvent infrastructure');
  }

  // Helper: emit the "KEY:num," prefix into tpe.
  // TODO: parameter type to TokenProcessEvent once ported.
  void _doPrefix(dynamic tpe, String num) {
    // tpe.append(tpe.getKey());
    // tpe.append(':');
    // tpe.append(num);
    // tpe.append(',');
  }

  // Helper: find the next value that has an '=' in [strings] after index [i].
  int _getNextValue(List<String> strings, int i) {
    for (int j = i + 1; j < strings.length; j++) {
      final tok = strings[j];
      final eqLoc = tok.indexOf('=');
      if (eqLoc != -1) {
        return int.parse(tok.substring(eqLoc + 1));
      }
    }
    return 1;
  }

  /// Returns the [Type] of objects this plugin processes.
  ///
  /// Always [CDOMObject] in the Java implementation.
  ///
  /// TODO: return CDOMObject once ported.
  Type getProcessedClass() => dynamic;
}
