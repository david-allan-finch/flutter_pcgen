//
// Copyright 2001 (C) Greg Bingleman <byngl@hotmail.com>
// Copyright 2003 (C) Jonas Karlson <jujutsunerd@sf.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.kit.BaseKit
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
