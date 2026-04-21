//
// Copyright (c) Thomas Parker, 2016.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.output.channel.ChannelUtilities

/// Utilities for reading/writing character channel variables.
class ChannelUtilities {
  ChannelUtilities._();

  /// Reads the current value of a variable for the given CharID.
  static dynamic readControlledChannel(String charId, String variableName) {
    // TODO: read from VariableStore via SolverManagerFacet
    return null;
  }

  /// Writes a value to a variable for the given CharID.
  static void setControlledChannel(String charId, String variableName, dynamic value) {
    // TODO: write to VariableStore via SolverManagerFacet
  }
}
