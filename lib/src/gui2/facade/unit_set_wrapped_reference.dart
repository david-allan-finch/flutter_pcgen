//
// Copyright (c) Thomas Parker, 2018-9.
//
// This program is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.gui2.facade.UnitSetWrappedReference

import '../../facade/util/abstract_reference_facade.dart';
import '../../facade/util/writeable_reference_facade.dart';

/// A decorator for a WriteableReferenceFacade that converts an underlying value
/// into a value that is converted to the current unit set.
class UnitSetWrappedReference extends AbstractReferenceFacade<num>
    implements WriteableReferenceFacade<num> {
  /// The underlying WriteableReferenceFacade containing the uncorrected value.
  final WriteableReferenceFacade<num> _underlyingRef;

  /// The function used to convert the uncorrected value to the current unit set.
  final num Function(num) _toUnitSet;

  /// The function used to convert a corrected value (in the current unit set)
  /// to an uncorrected value.
  final num Function(num) _fromUnitSet;

  UnitSetWrappedReference._(
      this._underlyingRef, this._toUnitSet, this._fromUnitSet);

  @override
  num? get() {
    num? underlying = _underlyingRef.get();
    return underlying == null ? null : _toUnitSet(underlying);
  }

  @override
  void set(num? obj) {
    num? toSet = obj == null ? null : _fromUnitSet(obj);
    _underlyingRef.set(toSet);
  }

  /// Factory to avoid the constructor leaking [this] into another object.
  static UnitSetWrappedReference getReference(
    WriteableReferenceFacade<num> underlyingRef,
    num Function(num) toUnitSet,
    num Function(num) fromUnitSet,
  ) {
    final wrappedRef =
        UnitSetWrappedReference._(underlyingRef, toUnitSet, fromUnitSet);
    underlyingRef.addReferenceListener((refEvent) {
      num? oldRef = refEvent.oldReference;
      num? oldValue = oldRef == null ? null : toUnitSet(oldRef);
      num? newRef = refEvent.newReference;
      num? newValue = newRef == null ? null : toUnitSet(newRef);
      wrappedRef.fireReferenceChangedEvent(wrappedRef, oldValue, newValue);
    });
    return wrappedRef;
  }
}
