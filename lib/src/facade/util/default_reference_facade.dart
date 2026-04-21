//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.facade.util.DefaultReferenceFacade
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_pcgen/src/facade/util/reference_facade.dart';

// Mutable, observable reference to a single value.
// Extends ChangeNotifier so Flutter widgets can use addListener/removeListener
// directly, while also supporting the typed ReferenceChangeEvent API.
class DefaultReferenceFacade<E> extends ChangeNotifier implements ReferenceFacade<E> {
  E? _object;
  final List<void Function(ReferenceChangeEvent<E>)> _referenceListeners = [];

  DefaultReferenceFacade([this._object]);

  @override
  E? get() => _object;

  void set(E? object) {
    if (_object == object) return;
    final old = _object;
    _object = object;
    final event = ReferenceChangeEvent<E>(this, old, object);
    for (final l in List.of(_referenceListeners)) l(event);
    notifyListeners();
  }

  @override
  void addReferenceListener(void Function(ReferenceChangeEvent<E>) listener) {
    _referenceListeners.add(listener);
  }

  @override
  void removeReferenceListener(void Function(ReferenceChangeEvent<E>) listener) {
    _referenceListeners.remove(listener);
  }

  @override
  String toString() => _object.toString();
}
