import 'package:flutter_pcgen/src/formula/base/implemented_scope.dart';

abstract interface class ScopeImplementer {
  ImplementedScope getImplementedScope(String scopeName);
}
