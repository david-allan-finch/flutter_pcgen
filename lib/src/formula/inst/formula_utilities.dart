import '../base/evaluation_manager.dart';
import '../base/function_library.dart';
import '../base/operator_library.dart';
import '../base/scope_implementer.dart';
import '../base/scope_instance.dart';
import '../base/scope_instance_factory.dart';
import '../base/variable_library.dart';
import '../base/variable_store.dart';
import 'simple_function_library.dart';
import 'simple_operator_library.dart';
import '../operator/number/number_add.dart';
import '../operator/number/number_subtract.dart';
import '../operator/number/number_multiply.dart';
import '../operator/number/number_divide.dart';
import '../operator/number/number_exp.dart';
import '../operator/number/number_remainder.dart';
import '../operator/bool/boolean_and.dart';
import '../operator/bool/boolean_or.dart';
import '../operator/bool/boolean_not.dart';
import '../function/abs_function.dart';
import '../function/min_function.dart';
import '../function/max_function.dart';
import '../function/floor_function.dart';
import '../function/ceil_function.dart';
import '../function/round_function.dart';
import '../function/if_function.dart';

class FormulaUtilities {
  FormulaUtilities._();

  static SimpleOperatorLibrary buildStandardOperatorLibrary() {
    final lib = SimpleOperatorLibrary();
    lib.addAction(NumberAdd());
    lib.addAction(NumberSubtract());
    lib.addAction(NumberMultiply());
    lib.addAction(NumberDivide());
    lib.addAction(NumberExp());
    lib.addAction(NumberRemainder());
    lib.addAction(BooleanAnd());
    lib.addAction(BooleanOr());
    lib.addUnaryAction(BooleanNot());
    return lib;
  }

  static SimpleFunctionLibrary buildStandardFunctionLibrary() {
    final lib = SimpleFunctionLibrary();
    lib.addFunction(AbsFunction());
    lib.addFunction(MinFunction());
    lib.addFunction(MaxFunction());
    lib.addFunction(FloorFunction());
    lib.addFunction(CeilFunction());
    lib.addFunction(RoundFunction());
    lib.addFunction(IfFunction());
    return lib;
  }

  static EvaluationManager buildEvaluationManager({
    required ScopeImplementer scopeLib,
    required FunctionLibrary functionLib,
    required VariableLibrary varLib,
    required VariableStore results,
    required ScopeInstanceFactory siFactory,
    required OperatorLibrary opLib,
    required ScopeInstance instance,
  }) {
    return EvaluationManager()
        .getWith(EvaluationManager.scopelib, scopeLib)
        .getWith(EvaluationManager.function, functionLib)
        .getWith(EvaluationManager.varlib, varLib)
        .getWith(EvaluationManager.results, results)
        .getWith(EvaluationManager.sifactory, siFactory)
        .getWith(EvaluationManager.oplib, opLib)
        .getWith(EvaluationManager.instance, instance);
  }
}
