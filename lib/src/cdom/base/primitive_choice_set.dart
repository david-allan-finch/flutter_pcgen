//
// Copyright 2007, 2008 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.base.PrimitiveChoiceSet
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';

// PrimitiveChoiceSet contains references to objects (often CDOMObjects) and
// can resolve its contents given a PlayerCharacter.
abstract interface class PrimitiveChoiceSet<T> {
  /// Returns the objects contained in this set for the given PlayerCharacter.
  Iterable<T> getSet(dynamic pc);

  /// Returns the runtime Type of the objects in this set.
  Type getChoiceClass();

  /// Returns an LST representation suitable for storing in a data file.
  String getLSTformat([bool useAny = false]);

  /// Returns the GroupingState indicating how this set can be combined.
  GroupingState getGroupingState();

  // Sentinel "invalid" singleton.
  static final PrimitiveChoiceSet _invalid = _InvalidPrimitiveChoiceSet();

  static PrimitiveChoiceSet<T> getInvalid<T>() => _invalid as PrimitiveChoiceSet<T>;
}

class _InvalidPrimitiveChoiceSet implements PrimitiveChoiceSet<Object> {
  @override
  Iterable<Object> getSet(dynamic pc) => const [];

  @override
  Type getChoiceClass() => Object;

  @override
  GroupingState getGroupingState() => GroupingState.invalid;

  @override
  String getLSTformat([bool useAny = false]) => 'ERROR';
}
