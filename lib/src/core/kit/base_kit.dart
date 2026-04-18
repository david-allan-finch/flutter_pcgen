import '../../cdom/base/concrete_prereq_object.dart';
import '../../cdom/base/loadable.dart';
import '../kit.dart';
import '../player_character.dart';

class OptionBound {
  final String min; // formula string
  final String max; // formula string
  OptionBound(this.min, this.max);

  bool isOption(PlayerCharacter pc, int val) {
    final minVal = pc.getVariableValue(min, '').toInt();
    final maxVal = pc.getVariableValue(max, '').toInt();
    return val >= minVal && val <= maxVal;
  }
}

// Common base class for all kit task types.
abstract class BaseKit extends ConcretePrereqObject implements Loadable {
  String? _sourceURI;
  List<OptionBound>? bounds;

  void setOptionBounds(String min, String max) {
    bounds ??= [];
    bounds!.add(OptionBound(min, max));
  }

  bool isOption(PlayerCharacter pc, int val) {
    if (bounds != null) {
      for (final bound in bounds!) {
        if (bound.isOption(pc, val)) return true;
      }
    }
    return false;
  }

  bool isOptional() => bounds != null;

  List<OptionBound>? getBounds() =>
      bounds == null ? null : List.unmodifiable(bounds!);

  // Evaluate EVAL(...) expressions in a string using pc variable values.
  static String eval(PlayerCharacter aPC, String aValue) {
    String ret = aValue;
    int evalInd = ret.indexOf('EVAL(');
    while (evalInd != -1) {
      final evalStr = ret.substring(evalInd);
      final prefix = ret.substring(0, evalInd);
      int nestingLevel = 1;
      int startInd = 4;
      int endInd = startInd + 1;
      while (endInd < evalStr.length - 1) {
        final c = evalStr[endInd];
        if (c == '(') {
          nestingLevel++;
        } else if (c == ')') {
          nestingLevel--;
          if (nestingLevel == 0) break;
        }
        endInd++;
      }
      if (nestingLevel != 0) return aValue;
      final expr = evalStr.substring(5, endInd);
      final val = aPC.getVariableValue(expr, '').toInt();
      ret = prefix + val.toString() + ret.substring(evalInd + endInd + 1);
      evalInd = ret.indexOf('EVAL(');
    }
    return ret;
  }

  // Test applying this kit item to a PC. Returns true if OK.
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings);

  // Apply this kit item to a PC.
  void apply(PlayerCharacter aPC);

  // Human-readable name for this kit object type.
  String getObjectName();

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  String? getDisplayName() => null;

  @override
  void setName(String name) {}

  @override
  String? getKeyName() => null;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;
}
