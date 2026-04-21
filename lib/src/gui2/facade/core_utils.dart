// Translation of pcgen.gui2.facade.CoreUtils

import '../../core/player_character.dart';
import '../../facade/core/core_view_node_facade.dart';
import '../../util/logging.dart';

/// Utility class for core debug view operations.
final class CoreUtils {
  CoreUtils._();

  /// Build a list of core debug nodes for the given perspective.
  static List<CoreViewNodeFacade> buildCoreDebugList(
      PlayerCharacter pc, dynamic pers) {
    List<CoreViewNodeFacade> coreViewList = [];
    // Simplified: gather locations from perspective DB and build view nodes
    List<Object> locations = _getLocations(pers);
    Map<dynamic, _LocationCoreViewNode> facetToNode = {};
    Map<dynamic, List<dynamic>> sources = {};

    for (Object location in locations) {
      dynamic view = _getView(pers, location);
      _LocationCoreViewNode node = _LocationCoreViewNode(location);
      facetToNode[view] = node;
      coreViewList.add(node);
      for (dynamic listener in _getChildren(view)) {
        dynamic lView = _getViewOfFacet(listener);
        dynamic src = lView ?? listener;
        sources.putIfAbsent(src, () => []).add(view);
      }
      List<Object>? parents = _getVirtualParents(view);
      if (parents != null) {
        for (Object parent in parents) {
          dynamic parentView = _getViewOfFacet(parent);
          if (parentView == null) {
            Logging.errorPrint(
                'Expected $parent to be a registered Facet in Perspective $pers');
          }
          sources.putIfAbsent(view, () => []).add(parentView);
        }
      }
    }

    for (Object location in locations) {
      dynamic view = _getView(pers, location);
      _LocationCoreViewNode node = facetToNode[view]!;
      for (dynamic obj in _getSet(view, pc)) {
        List<String> sourceDesc = [];
        for (dynamic src in _getSources(view, pc, obj)) {
          if (_isIdentified(src)) {
            sourceDesc.add(_getLoadId(src));
          } else {
            dynamic srcView = _getViewOfFacet(src);
            if (srcView == null) {
              sourceDesc.add('Orphaned [${src.runtimeType}]');
            } else if (facetToNode[srcView] == null) {
              sourceDesc.add(
                  'Other Perspective [${_getPerspectiveOfFacet(src)}: ${_getDescription(srcView)}]');
            }
          }
        }
        _ObjectCoreViewNode sourceNode =
            _ObjectCoreViewNode(pc, obj, sourceDesc);
        sourceNode.addGrantedByNode(node);
        coreViewList.add(sourceNode);
      }
    }

    for (Object location in locations) {
      dynamic view = _getView(pers, location);
      _LocationCoreViewNode node = facetToNode[view]!;
      List<dynamic>? facetInputs = sources[view];
      if (facetInputs != null) {
        for (dynamic facet in facetInputs) {
          facetToNode[facet]?.addGrantedByNode(node);
        }
      }
    }
    return coreViewList;
  }

  static String _getLoadId(dynamic obj) {
    if (obj is _IdentifiedObj) {
      String name = obj.displayName;
      String id = '${obj.runtimeType}: $name';
      if (obj.keyName != name) {
        id = '$id [${obj.keyName}]';
      }
      return id;
    } else if (obj is _QualifiedObjectObj) {
      return _getLoadId(obj.rawObject);
    } else if (obj is _CDOMReferenceObj) {
      return '${obj.referenceClass}: ${obj.lstFormat}';
    } else {
      return '${obj.runtimeType}: $obj';
    }
  }

  static String _getRequirementsInfo(PlayerCharacter pc, dynamic object) {
    if (object is _PrereqObjectObj) {
      dynamic source = (object is _CDOMObjectObj) ? object : null;
      return '<html>'
          '${_preReqHTMLStrings(pc, source)}'
          '${_getAllowInfo(pc, source)}'
          '</html>';
    }
    return '';
  }

  // Stubs for Java API calls — wire to real implementations as available
  static List<Object> _getLocations(dynamic pers) => [];
  static dynamic _getView(dynamic pers, Object location) => null;
  static List<dynamic> _getChildren(dynamic view) => [];
  static dynamic _getViewOfFacet(dynamic facet) => null;
  static List<Object>? _getVirtualParents(dynamic view) => null;
  static Iterable<dynamic> _getSet(dynamic view, PlayerCharacter pc) => [];
  static List<dynamic> _getSources(
      dynamic view, PlayerCharacter pc, dynamic obj) => [];
  static bool _isIdentified(dynamic obj) => false;
  static dynamic _getPerspectiveOfFacet(dynamic src) => null;
  static String _getDescription(dynamic view) => '';
  static String _preReqHTMLStrings(PlayerCharacter pc, dynamic source) => '';
  static String _getAllowInfo(PlayerCharacter pc, dynamic source) => '';
}

// Placeholder marker interfaces for type checks
abstract class _IdentifiedObj {
  String get displayName;
  String get keyName;
}

abstract class _QualifiedObjectObj {
  dynamic get rawObject;
}

abstract class _CDOMReferenceObj {
  dynamic get referenceClass;
  String get lstFormat;
}

abstract class _PrereqObjectObj {}

abstract class _CDOMObjectObj {}

// ---------------------------------------------------------------------------

abstract class _CoreViewNodeBase implements CoreViewNodeFacade {
  final List<CoreViewNodeFacade> _grantedByNodes = [];

  void addGrantedByNode(CoreViewNodeFacade node) {
    _grantedByNodes.add(node);
  }

  List<CoreViewNodeFacade> get grantedByNodes => List.unmodifiable(_grantedByNodes);
}

class _LocationCoreViewNode<T> extends _CoreViewNodeBase {
  final Object object;

  _LocationCoreViewNode(this.object);

  @override
  String get nodeType => 'Location';

  @override
  String get key => object.toString();

  @override
  String get source => '';

  @override
  String get requirements => '';

  @override
  String toString() => CoreUtils._getLoadId(object);
}

class _ObjectCoreViewNode<T> extends _CoreViewNodeBase {
  final T object;
  final List<String> sourceDesc;
  final PlayerCharacter pc;

  _ObjectCoreViewNode(this.pc, this.object, this.sourceDesc);

  @override
  String get nodeType => 'Source';

  @override
  String get key {
    if (object is _CDOMObjectObj) {
      return (object as dynamic).keyName as String;
    }
    return object.toString();
  }

  @override
  String get source => sourceDesc.join(', ');

  @override
  String get requirements => CoreUtils._getRequirementsInfo(pc, object);

  @override
  String toString() => CoreUtils._getLoadId(object);
}
