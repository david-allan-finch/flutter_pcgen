import '../base/concrete_prereq_object.dart';

// A named field (aspect) on an Ability, with optional variable substitution.
// Format: ASPECT:Speed|%1 ft|MovementRate — %1 replaced with variable #1.
class Aspect extends ConcretePrereqObject {
  final String key; // AspectName
  final List<String> _components = [];
  List<String>? _variables;

  static const String _varName = '%NAME';
  static const String _varList = '%LIST';
  static const String _varMarker = r'$$VAR:';

  Aspect(this.key, String aString) {
    _parseAspectString(aString);
  }

  void _parseAspectString(String aString) {
    // Split on %N placeholders
    final buf = StringBuffer();
    int i = 0;
    while (i < aString.length) {
      if (aString[i] == '%' && i + 1 < aString.length) {
        final next = aString[i + 1];
        if (next == '%') {
          buf.write('%');
          i += 2;
          continue;
        }
        if (next == 'N' && aString.startsWith('NAME', i + 1)) {
          if (buf.isNotEmpty) { _components.add(buf.toString()); buf.clear(); }
          _components.add(_varName);
          i += 5;
          continue;
        }
        if (next == 'L' && aString.startsWith('LIST', i + 1)) {
          if (buf.isNotEmpty) { _components.add(buf.toString()); buf.clear(); }
          _components.add(_varList);
          i += 5;
          continue;
        }
        if (int.tryParse(next) != null) {
          if (buf.isNotEmpty) { _components.add(buf.toString()); buf.clear(); }
          _components.add('$_varMarker$next');
          i += 2;
          continue;
        }
      }
      buf.write(aString[i]);
      i++;
    }
    if (buf.isNotEmpty) _components.add(buf.toString());
  }

  void addVariable(String var_) {
    _variables ??= [];
    _variables!.add(var_);
  }

  /// Evaluate the aspect string, replacing %1, %NAME, etc.
  String getAspectText(dynamic pc, dynamic ability) {
    final buf = StringBuffer();
    for (final comp in _components) {
      if (comp.startsWith(_varMarker)) {
        final idx = int.tryParse(comp.substring(_varMarker.length)) ?? 1;
        final vars = _variables;
        if (vars != null && idx >= 1 && idx <= vars.length) {
          buf.write(vars[idx - 1]);
        }
      } else if (comp == _varName) {
        if (ability != null) buf.write(ability.toString());
      } else if (comp == _varList) {
        // %LIST — would join associated choices
        buf.write('LIST');
      } else {
        buf.write(comp);
      }
    }
    return buf.toString();
  }

  @override
  String toString() => '$key:${_components.join()}';
}
