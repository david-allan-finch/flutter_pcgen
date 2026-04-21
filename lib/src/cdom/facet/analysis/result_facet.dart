/*
 * Copyright (c) Thomas Parker, 2015.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
 */

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';

/// ResultFacet is a consolidated location to determine the value of a variable.
/// This gives a location where a system can request in terms of owning object
/// and variable name (string) and the conversion to VariableID is done
/// internally to this Facet in order to then get the result from the
/// appropriate VariableStore.
class ResultFacet {
  dynamic scopeFacet;
  dynamic variableStoreFacet;

  dynamic getGlobalVariable(CharID id, String varName) {
    // VariableUtilities.getGlobalVariableID(id, varName)
    final varID = _getGlobalVariableID(id, varName);
    return variableStoreFacet.getValue(id, varID);
  }

  dynamic getLocalVariable(CharID id, dynamic cdo, String varName) {
    final localScopeName = cdo.getLocalScopeName();
    if (localScopeName == null) {
      return getGlobalVariable(id, varName);
    }

    final scope = scopeFacet.get(id, localScopeName, cdo);
    if (scope == null) {
      // Logging.errorPrint: improperly built object had no VariableScope
      return null;
    }
    final varID = _getLocalVariableID(id, scope, varName);
    return variableStoreFacet.getValue(id, varID);
  }

  dynamic _getGlobalVariableID(CharID id, String varName) {
    // TODO: wire to VariableUtilities.getGlobalVariableID
    return varName;
  }

  dynamic _getLocalVariableID(CharID id, dynamic scope, String varName) {
    // TODO: wire to VariableUtilities.getLocalVariableID
    return varName;
  }

  void setScopeFacet(dynamic scopeFacet) {
    this.scopeFacet = scopeFacet;
  }

  void setVariableStoreFacet(dynamic variableStoreFacet) {
    this.variableStoreFacet = variableStoreFacet;
  }
}
