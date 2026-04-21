//
// Copyright (c) Thomas Parker, 2013-14.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.meta.SingleSourceListFacetView
import 'package:flutter_pcgen/src/cdom/meta/facet_view.dart';

// FacetView backed by an AbstractSingleSourceListFacet.
class SingleSourceListFacetView<T> implements FacetView<T> {
  final dynamic _facet; // AbstractSingleSourceListFacet<T, ?>

  SingleSourceListFacetView(dynamic facet) : _facet = facet;

  @override
  List<T> getSet(dynamic id) =>
      List<T>.from(_facet.getSet(id) as Iterable);

  @override
  List<Object> getSources(dynamic id, T obj) {
    final source = _facet.getSource(id, obj);
    return source != null ? [source] : [];
  }

  @override
  List<Object> getChildren() =>
      List<Object>.from(_facet.getDataFacetChangeListeners() as Iterable);

  @override
  String getDescription() => _facet.toString();

  @override
  bool represents(Object src) => _facet == src;
}
