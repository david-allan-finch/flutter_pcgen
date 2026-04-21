//
// Copyright 2006 (C) Aaron Divinsky <boomer70@yahoo.com>
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
// Translation of pcgen.core.Description
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';

/// Represents a generic description field.
///
/// Supports one or more prerequisites and variable substitution on the
/// description string itself. Variable substitution replaces %# with the
/// #th variable in the variable list.
class Description extends ConcretePrereqObject {
  final List<String> _components = [];
  List<String>? _variables;

  static const String _varName = '%NAME';
  static const String _varChoice = '%CHOICE';
  static const String _varList = '%LIST';
  static const String _varFeats = '%FEAT=';
  static const String _varMarker = r'$$VAR:';

  /// Construct a Description from a description string.
  Description(String aString) {
    int currentInd = 0;
    int percentInd;

    while ((percentInd = aString.indexOf('%', currentInd)) != -1) {
      final preText = aString.substring(currentInd, percentInd);
      if (preText.isNotEmpty) {
        _components.add(preText);
      }

      if (percentInd == aString.length - 1) {
        _components.add('%');
        return;
      }

      if (aString[percentInd + 1] == '{') {
        // Bracketed placeholder: %{N}
        final closeIdx = aString.indexOf('}', percentInd + 1);
        currentInd = closeIdx + 1;
        final replacement = aString.substring(percentInd + 1, currentInd);
        _components.add(_varMarker + replacement);
      } else if (aString[percentInd + 1] == '%') {
        // Escaped percent: %%
        currentInd = percentInd + 2;
        _components.add('%');
      } else {
        // Unbracketed numeric placeholder: %N
        currentInd = percentInd + 1;
        while (currentInd < aString.length) {
          final val = aString[currentInd];
          if (int.tryParse(val) != null) {
            currentInd++;
          } else {
            break;
          }
        }
        if (currentInd > percentInd + 1) {
          _components.add(_varMarker + aString.substring(percentInd + 1, currentInd));
        } else {
          _components.add(aString.substring(percentInd, percentInd + 1));
          // Log a warning: bare % in description should be escaped or parameterized
        }
      }
    }

    _components.add(aString.substring(currentInd));
  }

  /// Adds a variable to use in variable substitution.
  void addVariable(String aVariable) {
    _variables ??= [];
    _variables!.add(aVariable);
  }

  /// Gets the description string after having tested all prereqs and
  /// substituting all variables.
  ///
  /// [aPC] is a dynamic reference to PlayerCharacter to avoid circular imports.
  /// [objList] is the list of CDOMObjects providing context.
  String getDescription(dynamic aPC, List<Object> objList) {
    if (objList.isEmpty) return '';

    final b = objList.first;

    // Check if PC qualifies for this description
    // (qualifies() check would use prereq system - simplified here)
    final buf = StringBuffer();
    for (final comp in _components) {
      if (comp.startsWith(_varMarker)) {
        final indStr = comp.substring(_varMarker.length);
        // Handle both {N} and N forms
        final cleanInd = indStr.startsWith('{') ? indStr.substring(1, indStr.length - 1) : indStr;
        final ind = int.tryParse(cleanInd);
        if (ind == null || _variables == null || ind > _variables!.length) {
          continue;
        }
        final varValue = _variables![ind - 1];
        if (varValue == _varName) {
          // Get output name from the object
          try {
            buf.write((b as dynamic).getOutputName());
          } catch (_) {
            buf.write(b.toString());
          }
        } else if (varValue == _varChoice) {
          // %CHOICE - get first association from PC
          try {
            if (aPC != null && (aPC as dynamic).hasAssociations(b)) {
              final assocList = (aPC as dynamic).getAssociationExportList(b) as List;
              if (assocList.isNotEmpty) {
                buf.write(assocList.first.toString());
              }
            }
          } catch (_) {}
        } else if (varValue == _varList) {
          // %LIST - get all associations joined
          final assocList = <String>[];
          for (final obj in objList) {
            try {
              if (aPC != null && (aPC as dynamic).hasAssociations(obj)) {
                final objAssoc = (aPC as dynamic).getAssociationExportList(obj) as List;
                assocList.addAll(objAssoc.map((e) => e.toString()));
              }
            } catch (_) {}
          }
          assocList.sort();
          final joinString = assocList.length == 2 ? ' and ' : ', ';
          buf.write(assocList.join(joinString));
        } else if (varValue.startsWith(_varFeats)) {
          // %FEAT= - look up feat descriptions
          // Simplified stub - full implementation requires Globals context
        } else if (varValue.startsWith('"')) {
          // Literal string value
          buf.write(varValue.substring(1, varValue.length - 1));
        } else {
          // Variable formula - evaluate via PC
          try {
            if (aPC != null) {
              final val = (aPC as dynamic).getVariableValue(varValue, 'Description');
              buf.write((val as num).truncate());
            }
          } catch (_) {}
        }
      } else {
        buf.write(comp);
      }
    }
    return buf.toString();
  }

  /// Gets the Description tag in PCC/LST format.
  String getPCCText() {
    final buf = StringBuffer();
    for (final str in _components) {
      if (str.startsWith(_varMarker)) {
        final indStr = str.substring(_varMarker.length);
        final cleanInd = indStr.startsWith('{')
            ? indStr.substring(1, indStr.length - 1)
            : indStr;
        buf.write('%');
        buf.write(cleanInd);
      } else if (str == '%') {
        buf.write('%%');
      } else {
        buf.write(str);
      }
    }
    if (_variables != null) {
      for (final v in _variables!) {
        buf.write('|');
        buf.write(v);
      }
    }
    // Prerequisites would be appended here in a full implementation
    return buf.toString();
  }

  @override
  String toString() => getPCCText();

  @override
  int get hashCode =>
      _components.length +
      7 * getPrerequisiteCount() +
      31 * (_variables?.length ?? 0);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    if (o is! Description) return false;
    if (_variables == null && o._variables != null) return false;
    if (_variables != null && o._variables == null) return false;
    if (!_listEquals(_components, o._components)) return false;
    if (_variables != null && !_listEquals(_variables!, o._variables!)) return false;
    return true;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
