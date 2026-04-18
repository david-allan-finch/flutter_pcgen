import 'limited_var_container.dart';
import 'var_holder.dart';

// LimitedVarHolder combines VarHolder and LimitedVarContainer.
abstract interface class LimitedVarHolder
    implements VarHolder, LimitedVarContainer {
  // Combined interface – no additional members.
}
