// Translation of pcgen.output.channel.ChannelCompatibility

import '../compat/abstract_adapter.dart';

/// ChannelCompatibility provides access to writeable references for
/// character channel data (e.g. stats, alignment, gender).
class ChannelCompatibility {
  ChannelCompatibility._();

  /// Returns a writeable reference facade for the given CControl channel.
  static dynamic getWriteableRef(dynamic charId, dynamic control) {
    // TODO: resolve via ControlUtilities and SolverManager
    return null;
  }

  /// Returns a StatAdapter for the given stat key under a CControl channel.
  static AbstractAdapter? getStatAdapter(dynamic loadContext, dynamic control, dynamic stat) {
    // TODO: implement stat adapter lookup
    return null;
  }
}
