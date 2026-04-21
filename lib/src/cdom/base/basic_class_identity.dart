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
// Translation of pcgen.cdom.base.BasicClassIdentity
import 'class_identity.dart';

// BasicClassIdentity wraps a runtime Type and provides identity semantics.
// In Dart there is no reflective newInstance, so we accept a factory function.
class BasicClassIdentity<T> implements ClassIdentity<T> {
  final Type _underlyingClass;
  final String _simpleName;
  final T Function() _factory;

  BasicClassIdentity(Type cl, String simpleName, T Function() factory)
      : _underlyingClass = cl,
        _simpleName = simpleName,
        _factory = factory;

  @override
  String getName() => _simpleName;

  @override
  Type getReferenceClass() => _underlyingClass;

  @override
  T newInstance() => _factory();

  @override
  String getReferenceDescription() => _simpleName;

  @override
  bool isMember(T item) => item.runtimeType == _underlyingClass;

  @override
  String toString() => 'Identity: ${getReferenceDescription()}';

  @override
  int get hashCode => _underlyingClass.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is BasicClassIdentity) {
      return _underlyingClass == o._underlyingClass;
    }
    return false;
  }

  @override
  String getPersistentFormat() => getName().toUpperCase();

  static ClassIdentity<T> getIdentity<T>(Type cl, String simpleName, T Function() factory) {
    return BasicClassIdentity<T>(cl, simpleName, factory);
  }
}
