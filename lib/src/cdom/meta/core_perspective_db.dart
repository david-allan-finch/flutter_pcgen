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
