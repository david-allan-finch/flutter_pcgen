//
// Copyright 2018 (C) Tom Parker <thpr@sourceforge.net>
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
// Translation of pcgen.facade.util.AbstractReferenceFacade
import 'reference_facade.dart';

/// Base class for [ReferenceFacade] implementations providing listener
/// management and a fire helper method.
abstract class AbstractReferenceFacade<T> implements ReferenceFacade<T> {
  final List<void Function(ReferenceChangeEvent<T>)> _listeners = [];

  @override
  void addReferenceListener(void Function(ReferenceChangeEvent<T>) listener) {
    _listeners.add(listener);
  }

  @override
  void removeReferenceListener(
      void Function(ReferenceChangeEvent<T>) listener) {
    _listeners.remove(listener);
  }

  void fireReferenceChangedEvent(Object source, T? old, T? newer) {
    final event = ReferenceChangeEvent<T>(source, old, newer);
    for (final l in List.of(_listeners)) l(event);
  }
}
