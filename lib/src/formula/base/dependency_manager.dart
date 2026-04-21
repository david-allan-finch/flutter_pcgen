import 'package:flutter_pcgen/src/base/util/typed_key.dart';
import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'dependency_strategy.dart';
import 'dynamic_manager.dart';
import 'function_library.dart';
import 'implemented_scope.dart';
import 'indirect_dependency.dart';
import 'operator_library.dart';
import 'scope_instance.dart';
import 'scope_instance_factory.dart';
import 'scope_implementer.dart';
import 'variable_library.dart';
import 'variable_list.dart';

class DependencyManager {
  static final TypedKey<List<String>> log = TypedKey();
  static final TypedKey<ScopeImplementer> scopelib = TypedKey();
  static final TypedKey<VariableLibrary> varlib = TypedKey();
  static final TypedKey<FunctionLibrary> function = TypedKey();
  static final TypedKey<OperatorLibrary> oplib = TypedKey();
  static final TypedKey<ScopeInstanceFactory> sifactory = TypedKey();
  static final TypedKey<ImplementedScope?> scope = TypedKey(defaultValue: null);
  static final TypedKey<ScopeInstance> instance = TypedKey();
  static final TypedKey<FormatManager<dynamic>?> asserted = TypedKey(defaultValue: null);
  static final TypedKey<FormatManager<dynamic>?> inputFormat = TypedKey(defaultValue: null);
  static final TypedKey<DynamicManager> dynamic_ = TypedKey();
  static final TypedKey<VariableList?> variables = TypedKey(defaultValue: null);
  static final TypedKey<DependencyStrategy?> varStrategy = TypedKey(defaultValue: null);
  static final TypedKey<IndirectDependency?> indirects = TypedKey(defaultValue: null);

  final Map<TypedKey<dynamic>, Object?> _map = {};

  DependencyManager() {
    _map[log] = <String>[];
  }

  DependencyManager._fromMap(Map<TypedKey<dynamic>, Object?> inputs) {
    _map.addAll(inputs);
  }

  DependencyManager getWith<T>(TypedKey<T> key, T value) {
    final replacement = DependencyManager._fromMap(_map);
    replacement._map[key] = value;
    return replacement;
  }

  T? get<T>(TypedKey<T> key) {
    final value = _map[key];
    return value == null ? key.defaultValue : value as T;
  }
}
