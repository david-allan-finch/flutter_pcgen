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
// Translation of pcgen.facade.util.ListFacade
// Observable list abstraction for the facade layer.
abstract interface class ListFacade<E> implements Iterable<E> {
  void addListListener(void Function(ListChangeEvent<E>) listener);
  void removeListListener(void Function(ListChangeEvent<E>) listener);
  E getElementAt(int index);
  int getSize();
  bool isEmpty();
  bool containsElement(E element);
}

enum ListChangeType { added, removed, modified, contentsChanged }

class ListChangeEvent<E> {
  final Object source;
  final E? element;
  final int index;
  final ListChangeType type;
  const ListChangeEvent(this.source, this.element, this.index, this.type);
}
