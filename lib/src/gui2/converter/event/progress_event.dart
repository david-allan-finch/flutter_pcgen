//
// Copyright (c) 2006, 2009.
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
// Translation of pcgen.gui2.converter.event.ProgressEvent

/// Represents a progress event fired by a conversion sub-panel to signal
/// whether navigation to the next step is permitted.
class ProgressEvent {
  static const int allowed = 0;
  static const int notAllowed = 1;
  static const int autoAdvance = 2;

  /// The source object that fired this event.
  final Object source;

  /// The event identifier — one of [allowed], [notAllowed], or [autoAdvance].
  final int id;

  ProgressEvent(this.source, this.id);

  int getID() => id;
}
