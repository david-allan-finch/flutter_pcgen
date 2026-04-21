//
// Copyright (c) Thomas Parker, 2017-18.
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
// Translation of pcgen.cdom.helper.BridgeListener
// Bridges VariableListener / ReferenceListener events to an AbstractSourcedListFacet.
class BridgeListener {
  final dynamic _variableBridgeFacet; // AbstractSourcedListFacet<CharID, PCGenScoped>
  final dynamic _id; // CharID
  final Object _source;

  BridgeListener(dynamic id, dynamic variableBridgeFacet, Object source)
      : _id = id,
        _variableBridgeFacet = variableBridgeFacet,
        _source = source;

  void variableChanged(dynamic vcEvent) {
    _processChange(vcEvent.getOldValue(), vcEvent.getNewValue());
  }

  void referenceChanged(dynamic e) {
    _processChange(e.getOldReference(), e.getNewReference());
  }

  void _processChange(Object? oldValue, Object newValue) {
    if (newValue is List) {
      // Array-type variable: calculate identity difference
      final oldList = (oldValue as List?) ?? const [];
      final toRemove = oldList.where((e) => !newValue.contains(e));
      final toAdd = newValue.where((e) => !oldList.contains(e));
      for (final obj in toRemove) {
        _variableBridgeFacet.remove(_id, obj, _source);
      }
      for (final obj in toAdd) {
        _variableBridgeFacet.add(_id, obj, _source);
      }
    } else {
      if (oldValue != null) {
        _variableBridgeFacet.remove(_id, oldValue, _source);
      }
      _variableBridgeFacet.add(_id, newValue, _source);
    }
  }

  @override
  int get hashCode => (_id.hashCode * 31 + _variableBridgeFacet.hashCode) * 31 + _source.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is BridgeListener &&
      _id == obj._id &&
      _variableBridgeFacet == obj._variableBridgeFacet &&
      _source == obj._source;
}
