//
// Copyright 2012-18 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.ClassIdentity
// ClassIdentity uniquely identifies a type of object in PCGen, handling both
// plain class equality and categorized object equality (e.g. Abilities by Category).
abstract interface class ClassIdentity<T> {
  String getName();
  Type getReferenceClass();
  T newInstance();
  String getReferenceDescription();
  bool isMember(T item);
  String getPersistentFormat();
}
