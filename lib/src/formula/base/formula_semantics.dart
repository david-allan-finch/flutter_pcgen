import '../../../base/util/typed_key.dart';
import '../../../base/util/format_manager.dart';
import 'function_library.dart';
import 'implemented_scope.dart';
import 'operator_library.dart';
import 'scope_instance_factory.dart';
import 'scope_implementer.dart';
import 'variable_library.dart';

class FormulaSemantics {
  final Map<TypedKey<dynamic>, Object?> _map = {};

  static final TypedKey<ScopeImplementer> scopelib = TypedKey();
  static final TypedKey<FunctionLibrary> function = TypedKey();
  static final TypedKey<VariableLibrary> varlib = TypedKey();
  static final TypedKey<OperatorLibrary> oplib = TypedKey();
  static final TypedKey<ScopeInstanceFactory> sifactory = TypedKey();
  static final TypedKey<ImplementedScope> scope = TypedKey();
  static final TypedKey<FormatManager<dynamic>?> asserted = TypedKey(defaultValue: null);
  static final TypedKey<FormatManager<dynamic>?> inputFormat = TypedKey(defaultValue: null);

  FormulaSemantics();

  FormulaSemantics._fromMap(Map<TypedKey<dynamic>, Object?> inputs) {
    _map.addAll(inputs);
  }

  FormulaSemantics getWith<T>(TypedKey<T> key, T value) {
    final replacement = FormulaSemantics._fromMap(_map);
    replacement._map[key] = value;
    return replacement;
  }

  T? get<T>(TypedKey<T> key) {
    final value = _map[key];
    return value == null ? key.defaultValue : value as T;
  }
}
