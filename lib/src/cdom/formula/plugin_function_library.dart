// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.PluginFunctionLibrary

/// Singleton registry of formula functions loaded via plugin mechanism.
class PluginFunctionLibrary {
  static PluginFunctionLibrary? _instance;
  final List<dynamic> _functions = [];

  PluginFunctionLibrary._();

  static PluginFunctionLibrary getInstance() {
    return _instance ??= PluginFunctionLibrary._();
  }

  void loadPlugin(Type clazz) {
    // TODO: Dart plugin loading requires explicit registration, not reflection.
    // Individual formula functions register themselves via registerFunction().
  }

  void registerFunction(dynamic function) {
    if (_existingFunction(function.getFunctionName()) != null) {
      // Log: Duplicate function found
      return;
    }
    _functions.add(function);
  }

  dynamic _existingFunction(String name) {
    for (final f in _functions) {
      if ((f.getFunctionName() as String).toLowerCase() == name.toLowerCase()) {
        return f;
      }
    }
    return null;
  }

  List<dynamic> getFunctions() => List.unmodifiable(_functions);

  static void clear() => _instance?._functions.clear();
}
