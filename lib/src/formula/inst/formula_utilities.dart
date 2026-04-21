import 'package:flutter_pcgen/src/formula/base/evaluation_manager.dart';
import 'package:flutter_pcgen/src/formula/base/function_library.dart';
import 'package:flutter_pcgen/src/formula/base/operator_library.dart';
import 'package:flutter_pcgen/src/formula/base/scope_implementer.dart';
import 'package:flutter_pcgen/src/formula/base/scope_instance.dart';
import 'package:flutter_pcgen/src/formula/base/scope_instance_factory.dart';
import 'package:flutter_pcgen/src/formula/base/variable_library.dart';
import 'package:flutter_pcgen/src/formula/base/variable_store.dart';
import 'simple_function_library.dart';
import 'simple_operator_library.dart';
import 'package:flutter_pcgen/src/formula/operator/number/number_add.dart';
import 'package:flutter_pcgen/src/formula/operator/number/number_subtract.dart';
import 'package:flutter_pcgen/src/formula/operator/number/number_multiply.dart';
import 'package:flutter_pcgen/src/formula/operator/number/number_divide.dart';
import 'package:flutter_pcgen/src/formula/operator/number/number_exp.dart';
import 'package:flutter_pcgen/src/formula/operator/number/number_remainder.dart';
import 'package:flutter_pcgen/src/formula/operator/bool/boolean_and.dart';
import 'package:flutter_pcgen/src/formula/operator/bool/boolean_or.dart';
import 'package:flutter_pcgen/src/formula/operator/bool/boolean_not.dart';
import 'package:flutter_pcgen/src/formula/function/abs_function.dart';
import 'package:flutter_pcgen/src/formula/function/min_function.dart';
import 'package:flutter_pcgen/src/formula/function/max_function.dart';
import 'package:flutter_pcgen/src/formula/function/floor_function.dart';
import 'package:flutter_pcgen/src/formula/function/ceil_function.dart';
import 'package:flutter_pcgen/src/formula/function/round_function.dart';
import 'package:flutter_pcgen/src/formula/function/if_function.dart';

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
