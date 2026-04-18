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
