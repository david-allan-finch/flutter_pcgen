// Copyright (c) Thomas Parker, 2018-9.
//
// Translation of pcgen.cdom.formula.VariableUtilities

import '../../formula/base/variable_id.dart';
import '../enumeration/char_id.dart';

// TODO: Wire LoadContextFacet + ScopeFacet once those are translated.
// Until then, this stub throws to flag unimplemented paths.

/// Utility class for variable lookups in the new formula system.
abstract final class VariableUtilities {
  /// Returns the [VariableID] for a global variable named [variableName]
  /// on the PC identified by [id].
  static VariableID<T> getGlobalVariableID<T>(CharID id, String variableName) {
    throw UnimplementedError(
        'VariableUtilities.getGlobalVariableID requires LoadContextFacet/ScopeFacet');
  }
}
