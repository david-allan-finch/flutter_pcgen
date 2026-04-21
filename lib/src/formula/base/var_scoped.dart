import 'package:flutter_pcgen/src/formula/base/scope_instance.dart';

abstract interface class VarScoped {
  ScopeInstance? getScopeInstance();
  String getKeyName();
}
