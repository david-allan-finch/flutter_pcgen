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
// Translation of pcgen.facade.util.ReferenceFacade
// Observable reference (single value) abstraction for the facade layer.
abstract interface class ReferenceFacade<E> {
  E? get();
  void addReferenceListener(void Function(ReferenceChangeEvent<E>) listener);
  void removeReferenceListener(void Function(ReferenceChangeEvent<E>) listener);
}

class ReferenceChangeEvent<E> {
  final Object source;
  final E? oldValue;
  final E? newValue;
  const ReferenceChangeEvent(this.source, this.oldValue, this.newValue);
}
