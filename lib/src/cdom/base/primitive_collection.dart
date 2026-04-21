//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.PrimitiveCollection
import '../enumeration/grouping_state.dart';
import 'converter.dart';

// PrimitiveCollection can resolve itself to a typed collection given a
// PlayerCharacter and a Converter.
abstract interface class PrimitiveCollection<T> {
  List<R> getCollection<R>(dynamic pc, Converter<T, R> c);

  GroupingState getGroupingState();

  Type getReferenceClass();

  String getLSTformat(bool useAny);

  // Sentinel "invalid" singleton.
  static final PrimitiveCollection _invalid = _InvalidPrimitiveCollection();

  static PrimitiveCollection<T> getInvalid<T>() =>
      _invalid as PrimitiveCollection<T>;
}

// PrimLibrary provides a typed way to obtain the invalid PrimitiveCollection.
abstract interface class PrimLibrary {
  PrimitiveCollection<PCT> invalid<PCT>();
}

// FIXED is a PrimLibrary that always returns the invalid PrimitiveCollection.
final PrimLibrary fixed = _FixedPrimLibrary();

class _FixedPrimLibrary implements PrimLibrary {
  @override
  PrimitiveCollection<PCT> invalid<PCT>() => PrimitiveCollection.getInvalid<PCT>();
}

class _InvalidPrimitiveCollection implements PrimitiveCollection<Object> {
  @override
  List<R> getCollection<R>(dynamic pc, Converter<Object, R> c) => const [];

  @override
  GroupingState getGroupingState() => GroupingState.invalid;

  @override
  String getLSTformat(bool useAny) => 'ERROR';

  @override
  Type getReferenceClass() => Object;
}
