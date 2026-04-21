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
// Translation of pcgen.cdom.meta.ConvertingFacetView
import 'package:flutter_pcgen/src/cdom/meta/facet_view.dart';

// Holds a source-destination pair for ConvertingFacetView display.
class SourceDest {
  final Object _source;
  final Object? _dest;

  SourceDest(Object source, Object? dest)
      : _source = source,
        _dest = dest;

  Object getSource() => _source;
  Object? getDest() => _dest;

  @override
  String toString() => '$_source → $_dest';
}

// FacetView backed by an AbstractItemConvertingFacet.
class ConvertingFacetView<S, D> implements FacetView<Object> {
  final dynamic _facet; // AbstractItemConvertingFacet<S, D>

  ConvertingFacetView(dynamic facet) : _facet = facet;

  @override
  List<Object> getSet(dynamic id) {
    final sources = _facet.getSourceObjects(id) as Iterable;
    return sources.map<Object>((src) {
      final dest = _facet.getResultFor(id, src);
      return SourceDest(src as Object, dest);
    }).toList();
  }

  @override
  List<Object> getSources(dynamic id, Object obj) =>
      List<Object>.from(_facet.getSourcesFor(id, (obj as SourceDest).getSource()) as Iterable);

  @override
  List<Object> getChildren() =>
      List<Object>.from(_facet.getDataFacetChangeListeners() as Iterable);

  @override
  String getDescription() => _facet.toString();

  @override
  bool represents(Object src) => _facet == src;
}
