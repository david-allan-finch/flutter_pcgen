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
