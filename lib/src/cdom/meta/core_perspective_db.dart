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
// Translation of pcgen.cdom.meta.CorePerspectiveDB
import 'converting_facet_view.dart';
import 'core_perspective.dart';
import 'facet_behavior.dart';
import 'facet_view.dart';
import 'list_facet_view.dart';
import 'qualified_facet_view.dart';
import 'single_source_list_facet_view.dart';

// Registry mapping CorePerspective + FacetBehavior → FacetView for display.
final class CorePerspectiveDB {
  CorePerspectiveDB._();

  // (perspective, behavior/object) → FacetView
  static final Map<CorePerspective, Map<Object, FacetView>> _map = {};
  static final Map<CorePerspective, FacetView?> _rootMap = {};
  static final Map<Object, FacetView> _facetToView = {};
  static final Map<Object, CorePerspective> _facetToPerspective = {};
  static final Map<Object, List<Object>> _virtualParents = {};

  static Object registerConverting(CorePerspective perspective,
      FacetBehavior behavior, dynamic facet) {
    final view = ConvertingFacetView(facet);
    _finishRegistration(perspective, behavior, view, facet);
    return view;
  }

  static Object registerSourcedList(CorePerspective perspective,
      FacetBehavior behavior, dynamic facet) {
    final view = ListFacetView(facet);
    _finishRegistration(perspective, behavior, view, facet);
    return view;
  }

  static Object registerSingleSourceList(CorePerspective perspective,
      FacetBehavior behavior, dynamic facet) {
    final view = SingleSourceListFacetView(facet);
    _finishRegistration(perspective, behavior, view, facet);
    return view;
  }

  static Object registerQualified(CorePerspective perspective,
      FacetBehavior behavior, dynamic facet) {
    final view = QualifiedFacetView(facet);
    _finishRegistration(perspective, behavior, view, facet);
    return view;
  }

  static void _finishRegistration(CorePerspective perspective,
      FacetBehavior behavior, FacetView view, Object facet) {
    _map.putIfAbsent(perspective, () => {})[behavior] = view;
    _facetToView[facet] = view;
    _facetToPerspective[facet] = perspective;
  }

  static FacetView? getViewFor(CorePerspective perspective, Object behavior) =>
      _map[perspective]?[behavior];

  static CorePerspective? getPerspectiveFor(Object facet) =>
      _facetToPerspective[facet];

  static void addVirtualParent(Object child, Object parent) {
    _virtualParents.putIfAbsent(child, () => []).add(parent);
  }

  static List<Object> getVirtualParents(Object child) =>
      _virtualParents[child] ?? const [];
}
