//
// Copyright 2018 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.facade.util.VetoableReferenceFacade
import 'abstract_reference_facade.dart';
import 'reference_facade.dart';

/// A [WriteableReferenceFacade] that allows registered functions to veto
/// proposed changes. A veto function returns [true] to block the change.
class VetoableReferenceFacade<T> extends AbstractReferenceFacade<T> {
  T? _object;
  final List<bool Function(T? oldValue, T? newValue)> _vetoFunctions = [];

  VetoableReferenceFacade([this._object]);

  @override
  T? get() => _object;

  void addVetoToChannel(bool Function(T? oldValue, T? newValue) function) {
    _vetoFunctions.add(function);
  }

  void set(T? newValue) {
    for (final veto in _vetoFunctions) {
      if (veto(_object, newValue)) return; // vetoed
    }
    final old = _object;
    _object = newValue;
    fireReferenceChangedEvent(this, old, newValue);
  }
}
