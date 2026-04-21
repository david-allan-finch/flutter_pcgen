//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.util.event.ListDataAdapter

/// Adapter that listens to list data events and forwards to callbacks.
class ListDataAdapter {
  final void Function(int index0, int index1)? onIntervalAdded;
  final void Function(int index0, int index1)? onIntervalRemoved;
  final void Function(int index0, int index1)? onContentsChanged;

  ListDataAdapter({
    this.onIntervalAdded,
    this.onIntervalRemoved,
    this.onContentsChanged,
  });

  void intervalAdded(dynamic event) {
    onIntervalAdded?.call(event.index0 as int, event.index1 as int);
  }

  void intervalRemoved(dynamic event) {
    onIntervalRemoved?.call(event.index0 as int, event.index1 as int);
  }

  void contentsChanged(dynamic event) {
    onContentsChanged?.call(event.index0 as int, event.index1 as int);
  }
}
