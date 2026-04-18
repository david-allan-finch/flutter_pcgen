// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.RemoteModifierFacet

import '../enumeration/char_id.dart';
import '../formula/pcgen_scoped.dart';
import 'base/abstract_association_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/var_scoped_facet.dart';
import 'scope_facet.dart';
import 'solver_manager_facet.dart';

/// Tracks MODIFYOTHER: entries and applies them to targets in the solver system.
class RemoteModifierFacet
    extends AbstractAssociationFacet<CharID, dynamic, PCGenScoped>
    implements DataFacetChangeListener<CharID, PCGenScoped> {
  late ScopeFacet scopeFacet;
  late VarScopedFacet varScopedFacet;
  late SolverManagerFacet solverManagerFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, PCGenScoped> dfce) {
    final id = dfce.getCharID();
    final addedObject = dfce.getCDOMObject();

    // Apply existing remote modifiers to newly added object (if applicable)
    for (final remoteModifier in getSet(id)) {
      final modSource = get(id, remoteModifier);
      _processAdd(id, remoteModifier, addedObject, modSource);
    }

    // Register and apply this object's remote modifiers to existing objects
    final remoteModifierArray = addedObject.getRemoteModifierArray();
    if (remoteModifierArray.isNotEmpty) {
      final targets = varScopedFacet.getSet(id);
      for (final remoteModifier in remoteModifierArray) {
        set(id, remoteModifier, addedObject);
        for (final obj in targets) {
          _processAdd(id, remoteModifier, obj, addedObject);
        }
      }
    }
  }

  void _processAdd(CharID id, dynamic remoteModifier, PCGenScoped targetObject,
      PCGenScoped modSource) {
    final inst = scopeFacet.get(id, modSource);
    final varModifier = remoteModifier.getVarModifier();
    remoteModifier.getGrouping().process(targetObject, (target) {
      solverManagerFacet.addModifier(
          id, varModifier, target, varModifier.getModifier(), scopeFacet.get(id, target));
    });
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, PCGenScoped> dfce) {
    final id = dfce.getCharID();
    final addedObject = dfce.getCDOMObject();

    // Remove effects this object had from other objects' remote modifiers
    for (final remoteModifier in getSet(id)) {
      final modSource = get(id, remoteModifier);
      _processRemove(id, remoteModifier, addedObject, modSource);
    }

    // Remove this object's remote modifiers from existing targets
    final remoteModifierArray = addedObject.getRemoteModifierArray();
    if (remoteModifierArray.isNotEmpty) {
      final targets = varScopedFacet.getSet(id);
      for (final remoteModifier in remoteModifierArray) {
        remove(id, remoteModifier);
        for (final obj in targets) {
          _processRemove(id, remoteModifier, obj, addedObject);
        }
      }
    }
  }

  void _processRemove(CharID id, dynamic remoteModifier, dynamic targetObject,
      PCGenScoped modSource) {
    final varModifier = remoteModifier.getVarModifier();
    remoteModifier.getGrouping().process(modSource, (target) {
      solverManagerFacet.removeModifier(
          id, varModifier, target, varModifier.getModifier(), scopeFacet.get(id, target));
    });
  }

  void init() {
    varScopedFacet.addDataFacetChangeListener(this);
  }
}
