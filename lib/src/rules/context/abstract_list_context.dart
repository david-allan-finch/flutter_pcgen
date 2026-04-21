// Translated from pcgen/rules/context/AbstractListContext.java
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net> - LGPL 2.1+

import 'package:flutter_pcgen/src/base/util/hash_map_to_list.dart';
import 'package:flutter_pcgen/src/cdom/base/associated_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_list.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/base/master_list_interface.dart';
import 'package:flutter_pcgen/src/cdom/base/simple_associated_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/association_key.dart';
import 'associated_changes.dart';
import 'associated_collection_changes.dart';
import 'changes.dart';
import 'collection_changes.dart';
import 'list_changes.dart';
import 'list_commit_strategy.dart';

// ---------------------------------------------------------------------------
// OwnerURI — package-private helper (translated from private static class)
// ---------------------------------------------------------------------------

class OwnerURI {
  final CDOMObject owner;
  final String? source;

  OwnerURI(this.source, this.owner);

  @override
  int get hashCode => owner.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is OwnerURI) {
      if (source == null) {
        if (o.source != null) return false;
      } else {
        if (source != o.source) return false;
      }
      return owner == o.owner;
    }
    return false;
  }
}

// ---------------------------------------------------------------------------
// TrackingListCommitStrategy — translated from inner static class
// ---------------------------------------------------------------------------

/// A CDOMObject shell used as a tracking container. isType always returns false.
class CDOMShell extends CDOMObject {
  @override
  bool isType(String str) => false;
}

class TrackingListCommitStrategy implements ListCommitStrategy {
  // DoubleKeyMap<URI, CDOMObject, CDOMObject>  →  Map<String?, Map<CDOMObject, CDOMObject>>
  final Map<String?, Map<CDOMObject, CDOMObject>> _positiveMap = {};
  final Map<String?, Map<CDOMObject, CDOMObject>> _negativeMap = {};

  // TripleKeyMapToList<URI, CDOMObject, String, CDOMReference>
  //   → Map<String?, Map<CDOMObject, Map<String, List<CDOMReference>>>>
  final Map<String?, Map<CDOMObject, Map<String, List<CDOMReference<CDOMList<dynamic>>>>>> _globalClearSet = {};

  // TripleKeyMap<CDOMReference<list>, OwnerURI, CDOMObject, AssociatedPrereqObject>
  //   → Map<CDOMReference, Map<OwnerURI, Map<CDOMObject, AssociatedPrereqObject>>>
  final Map<CDOMReference<CDOMList<dynamic>>, Map<OwnerURI, Map<CDOMObject, AssociatedPrereqObject>>>
      positiveMasterMap = {};
  final Map<CDOMReference<CDOMList<dynamic>>, Map<OwnerURI, Map<CDOMObject, AssociatedPrereqObject>>>
      negativeMasterMap = {};

  // HashMapToList<CDOMReference<list>, OwnerURI>  →  Map<CDOMReference, List<OwnerURI>>
  final Map<CDOMReference<CDOMList<dynamic>>, List<OwnerURI>> _masterClearSet = {};

  // HashMapToList<String, OwnerURI>  →  Map<String, List<OwnerURI>>
  final Map<String, List<OwnerURI>> masterAllClear = {};

  String? _sourceURI;
  String? _extractURI;

  // ---- URI accessors ----

  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? sourceURI) => _sourceURI = sourceURI;

  @override
  void setExtractURI(String? extractURI) => _extractURI = extractURI;

  // ---- master list operations ----

  @override
  AssociatedPrereqObject addToMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMObject allowed,
  ) {
    final a = SimpleAssociatedObject();
    a.setAssociation(AssociationKey.owner, owner);
    a.setAssociation(AssociationKey.token, tokenName);
    final ouKey = OwnerURI(_sourceURI, owner);
    positiveMasterMap
        .putIfAbsent(list, () => {})
        .putIfAbsent(ouKey, () => {})[allowed] = a;
    return a;
  }

  @override
  void removeFromMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMObject allowed,
  ) {
    final a = SimpleAssociatedObject();
    a.setAssociation(AssociationKey.owner, owner);
    a.setAssociation(AssociationKey.token, tokenName);
    final ouKey = OwnerURI(_sourceURI, owner);
    negativeMasterMap
        .putIfAbsent(list, () => {})
        .putIfAbsent(ouKey, () => {})[allowed] = a;
  }

  @override
  Changes<CDOMReference<dynamic>> getMasterListChanges(
    String tokenName,
    CDOMObject owner,
    Type cl,
  ) {
    final lo = OwnerURI(_extractURI, owner);
    final list = <CDOMReference<dynamic>>[];

    outerPos:
    for (final ref in positiveMasterMap.keys) {
      if (ref.getReferenceClass() != cl) continue;
      final byOwner = positiveMasterMap[ref];
      if (byOwner == null) continue;
      final byChild = byOwner[lo];
      if (byChild == null) continue;
      for (final allowed in byChild.keys) {
        final assoc = byChild[allowed]!;
        if (owner == assoc.getAssociation(AssociationKey.owner) &&
            tokenName == assoc.getAssociation(AssociationKey.token)) {
          list.add(ref);
          continue outerPos;
        }
      }
    }

    final removelist = <CDOMReference<dynamic>>[];
    outerNeg:
    for (final ref in negativeMasterMap.keys) {
      if (ref.getReferenceClass() != cl) continue;
      final byOwner = negativeMasterMap[ref];
      if (byOwner == null) continue;
      final byChild = byOwner[lo];
      if (byChild == null) continue;
      for (final allowed in byChild.keys) {
        final assoc = byChild[allowed]!;
        if (owner == assoc.getAssociation(AssociationKey.owner) &&
            tokenName == assoc.getAssociation(AssociationKey.token)) {
          removelist.add(ref);
          continue outerNeg;
        }
      }
    }

    return CollectionChanges(list, removelist,
        masterAllClear[tokenName]?.contains(lo) ?? false);
  }

  @override
  AssociatedChanges<CDOMObject> getChangesInMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
  ) {
    final lo = OwnerURI(_extractURI, owner);

    final map = HashMapToList<CDOMObject, AssociatedPrereqObject>();
    final addedMap = positiveMasterMap[swl]?[lo] ?? {};
    for (final lw in addedMap.keys) {
      final apo = addedMap[lw]!;
      if (tokenName == apo.getAssociation(AssociationKey.token)) {
        map.addToListFor(lw, apo);
      }
    }

    final rmap = HashMapToList<CDOMObject, AssociatedPrereqObject>();
    final removedMap = negativeMasterMap[swl]?[lo] ?? {};
    for (final lw in removedMap.keys) {
      final apo = removedMap[lw]!;
      if (tokenName == apo.getAssociation(AssociationKey.token)) {
        rmap.addToListFor(lw, apo);
      }
    }

    final hasClear = _masterClearSet[swl]?.contains(lo) ?? false;
    return AssociatedCollectionChanges(
        map.isEmpty() ? null : map, rmap.isEmpty() ? null : rmap, hasClear);
  }

  void clearMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
  ) {
    _masterClearSet.putIfAbsent(list, () => []).add(OwnerURI(_sourceURI, owner));
  }

  @override
  void clearAllMasterLists(String tokenName, CDOMObject owner) {
    masterAllClear
        .putIfAbsent(tokenName, () => [])
        .add(OwnerURI(_sourceURI, owner));
  }

  // ---- positive / negative CDOMShell accessors ----

  CDOMObject _getPositive(String? source, CDOMObject cdo) {
    return _positiveMap
        .putIfAbsent(source, () => {})
        .putIfAbsent(cdo, () => CDOMShell());
  }

  CDOMObject _getNegative(String? source, CDOMObject cdo) {
    return _negativeMap
        .putIfAbsent(source, () => {})
        .putIfAbsent(cdo, () => CDOMShell());
  }

  // ---- list operations (regular — not master) ----

  @override
  AssociatedPrereqObject addToList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMReference<CDOMObject> allowed,
  ) {
    final a = SimpleAssociatedObject();
    a.setAssociation(AssociationKey.token, tokenName);
    _getPositive(_sourceURI, owner).putToList(list, allowed, a);
    return a;
  }

  @override
  AssociatedPrereqObject removeFromList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
    CDOMReference<CDOMObject> ref,
  ) {
    final a = SimpleAssociatedObject();
    a.setAssociation(AssociationKey.token, tokenName);
    _getNegative(_sourceURI, owner).putToList(swl, ref, a);
    return a;
  }

  @override
  void removeAllFromList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<dynamic>> swl,
  ) {
    _globalClearSet
        .putIfAbsent(_sourceURI, () => {})
        .putIfAbsent(owner, () => {})
        .putIfAbsent(tokenName, () => [])
        .add(swl);
  }

  @override
  List<CDOMReference<CDOMList<dynamic>>> getChangedLists(
    CDOMObject owner,
    Type cl,
  ) {
    final list = <CDOMReference<CDOMList<dynamic>>>{};

    for (final ref in _getPositive(_extractURI, owner).getModifiedLists()) {
      if (ref.getReferenceClass() == cl) list.add(ref);
    }
    for (final ref in _getNegative(_extractURI, owner).getModifiedLists()) {
      if (ref.getReferenceClass() == cl) list.add(ref);
    }

    final globalClearTokenKeys =
        _globalClearSet[_extractURI]?[owner]?.keys ?? <String>[];
    for (final key in globalClearTokenKeys) {
      final globalClearList =
          _globalClearSet[_extractURI]?[owner]?[key] ?? [];
      for (final ref in globalClearList) {
        if (ref.getReferenceClass() == cl) list.add(ref);
      }
    }
    return list.toList();
  }

  @override
  AssociatedChanges<CDOMReference<CDOMObject>> getChangesInList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
  ) {
    final tokenLists =
        _globalClearSet[_extractURI]?[owner]?[tokenName] ?? [];
    final hasGlobalClear = tokenLists.contains(swl);
    return ListChanges(
      tokenName,
      _getPositive(_extractURI, owner),
      _getNegative(_extractURI, owner),
      swl,
      hasGlobalClear,
    );
  }

  @override
  bool hasMasterLists() {
    return positiveMasterMap.isNotEmpty ||
        _masterClearSet.isNotEmpty ||
        masterAllClear.isNotEmpty;
  }

  void decommit() {
    masterAllClear.clear();
    _masterClearSet.clear();
    positiveMasterMap.clear();
    negativeMasterMap.clear();
    _positiveMap.clear();
    _negativeMap.clear();
    _globalClearSet.clear();
  }

  @override
  bool equalsTracking(ListCommitStrategy obj) {
    if (obj is TrackingListCommitStrategy) {
      return obj.masterAllClear == masterAllClear &&
          obj._masterClearSet == _masterClearSet &&
          obj.positiveMasterMap == positiveMasterMap &&
          obj.negativeMasterMap == negativeMasterMap;
    }
    return false;
  }

  void purge(CDOMObject cdo) {
    _positiveMap[_sourceURI]?.remove(cdo);
    _negativeMap[_sourceURI]?.remove(cdo);
    _globalClearSet[_sourceURI]?.remove(cdo);
  }
}

// ---------------------------------------------------------------------------
// AbstractListContext
// ---------------------------------------------------------------------------

abstract class AbstractListContext {
  final TrackingListCommitStrategy _edits = TrackingListCommitStrategy();

  void setSourceURI(String? sourceURI) {
    _edits.setSourceURI(sourceURI);
    getCommitStrategy().setSourceURI(sourceURI);
  }

  void setExtractURI(String? extractURI) {
    _edits.setExtractURI(extractURI);
    getCommitStrategy().setExtractURI(extractURI);
  }

  AssociatedPrereqObject addToMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMObject allowed,
  ) {
    return _edits.addToMasterList(tokenName, owner, list, allowed);
  }

  void removeFromMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMObject allowed,
  ) {
    _edits.removeFromMasterList(tokenName, owner, list, allowed);
  }

  void clearAllMasterLists(String tokenName, CDOMObject owner) {
    _edits.clearAllMasterLists(tokenName, owner);
  }

  AssociatedPrereqObject addToList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMReference<CDOMObject> allowed,
  ) {
    return _edits.addToList(tokenName, owner, list, allowed);
  }

  AssociatedPrereqObject removeFromList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
    CDOMReference<CDOMObject> ref,
  ) {
    return _edits.removeFromList(tokenName, owner, swl, ref);
  }

  void removeAllFromList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<dynamic>> swl,
  ) {
    _edits.removeAllFromList(tokenName, owner, swl);
  }

  void commit() {
    final commit = getCommitStrategy();

    // Positive master list
    for (final list in _edits.positiveMasterMap.keys) {
      _commitDirect(list);
    }
    // Negative master list
    for (final list in _edits.negativeMasterMap.keys) {
      _removeDirect(list);
    }

    // Global clear set: uri → owner → tokenName → list
    for (final uri in _edits._globalClearSet.keys) {
      final byOwner = _edits._globalClearSet[uri]!;
      for (final owner in byOwner.keys) {
        final byToken = byOwner[owner]!;
        for (final tokenName in byToken.keys) {
          for (final list in byToken[tokenName]!) {
            commit.removeAllFromList(tokenName, owner, list);
          }
        }
      }
    }

    // Negative map
    for (final uri in _edits._negativeMap.keys) {
      final byOwner = _edits._negativeMap[uri]!;
      for (final owner in byOwner.keys) {
        final neg = byOwner[owner]!;
        final modifiedLists = neg.getModifiedLists();
        for (final list in modifiedLists) {
          _remove(owner, neg, list);
        }
      }
    }

    // Positive map
    for (final uri in _edits._positiveMap.keys) {
      final byOwner = _edits._positiveMap[uri]!;
      for (final owner in byOwner.keys) {
        final pos = byOwner[owner]!;
        final modifiedLists = pos.getModifiedLists();
        for (final list in modifiedLists) {
          _add(owner, pos, list);
        }
      }
    }

    // Master all-clear
    for (final token in _edits.masterAllClear.keys) {
      for (final ou in _edits.masterAllClear[token]!) {
        commit.clearAllMasterLists(token, ou.owner);
      }
    }

    rollback();
  }

  void _commitDirect(CDOMReference<CDOMList<dynamic>> list) {
    final commit = getCommitStrategy();
    final byOwner = _edits.positiveMasterMap[list] ?? {};
    for (final ou in byOwner.keys) {
      final byChild = byOwner[ou] ?? {};
      for (final child in byChild.keys) {
        final assoc = byChild[child]!;
        final edge = commit.addToMasterList(
          assoc.getAssociation(AssociationKey.token) as String,
          ou.owner,
          list as CDOMReference<CDOMList<CDOMObject>>,
          child,
        );
        for (final ak in assoc.getAssociationKeys()) {
          _setAssoc(assoc, edge, ak);
        }
        edge.addAllPrerequisites(assoc.getPrerequisiteList());
      }
    }
  }

  void _removeDirect(CDOMReference<CDOMList<dynamic>> list) {
    final commit = getCommitStrategy();
    final byOwner = _edits.negativeMasterMap[list] ?? {};
    for (final ou in byOwner.keys) {
      final byChild = byOwner[ou] ?? {};
      for (final child in byChild.keys) {
        final assoc = byChild[child]!;
        commit.removeFromMasterList(
          assoc.getAssociation(AssociationKey.token) as String,
          ou.owner,
          list as CDOMReference<CDOMList<CDOMObject>>,
          child,
        );
      }
    }
  }

  void rollback() {
    _edits.decommit();
  }

  List<CDOMReference<CDOMList<dynamic>>> getChangedLists(
    CDOMObject owner,
    Type cl,
  ) {
    return getCommitStrategy().getChangedLists(owner, cl);
  }

  AssociatedChanges<CDOMReference<CDOMObject>> getChangesInList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
  ) {
    return getCommitStrategy().getChangesInList(tokenName, owner, swl);
  }

  AssociatedChanges<CDOMObject> getChangesInMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
  ) {
    return getCommitStrategy().getChangesInMasterList(tokenName, owner, swl);
  }

  Changes<CDOMReference<dynamic>> getMasterListChanges(
    String tokenName,
    CDOMObject owner,
    Type cl,
  ) {
    return getCommitStrategy().getMasterListChanges(tokenName, owner, cl);
  }

  bool hasMasterLists() {
    return getCommitStrategy().hasMasterLists();
  }

  void _remove(
    CDOMObject owner,
    CDOMObject neg,
    CDOMReference<CDOMList<dynamic>> list,
  ) {
    final commit = getCommitStrategy();
    final mods = neg.getListMods(list as CDOMReference<CDOMList<CDOMObject>>);
    for (final ref in mods.keys) {
      for (final assoc in neg.getListAssociations(
          list as CDOMReference<CDOMList<CDOMObject>>, ref)) {
        final token = assoc.getAssociation(AssociationKey.token) as String;
        final edge = commit.removeFromList(token, owner,
            list as CDOMReference<CDOMList<CDOMObject>>, ref);
        for (final ak in assoc.getAssociationKeys()) {
          _setAssoc(assoc, edge, ak);
        }
        edge.addAllPrerequisites(assoc.getPrerequisiteList());
      }
    }
  }

  void _add(
    CDOMObject owner,
    CDOMObject pos,
    CDOMReference<CDOMList<dynamic>> list,
  ) {
    final commit = getCommitStrategy();
    final mods = pos.getListMods(list as CDOMReference<CDOMList<CDOMObject>>);
    for (final ref in mods.keys) {
      for (final assoc in pos.getListAssociations(
          list as CDOMReference<CDOMList<CDOMObject>>, ref)) {
        final token = assoc.getAssociation(AssociationKey.token) as String;
        final edge = commit.addToList(token, owner,
            list as CDOMReference<CDOMList<CDOMObject>>, ref);
        for (final ak in assoc.getAssociationKeys()) {
          _setAssoc(assoc, edge, ak);
        }
        edge.addAllPrerequisites(assoc.getPrerequisiteList());
      }
    }
  }

  void _setAssoc(
    AssociatedPrereqObject assoc,
    AssociatedPrereqObject edge,
    dynamic ak,
  ) {
    edge.setAssociation(ak, assoc.getAssociation(ak));
  }

  bool masterListsEqual(AbstractListContext lc) {
    return getCommitStrategy().equalsTracking(lc.getCommitStrategy());
  }

  /// Clone associations to the new object in any master lists that reference
  /// the old object.
  void cloneInMasterLists(CDOMObject cdoOld, CDOMObject cdoNew) {
    // stub: SettingsHandler.getGameAsProperty().get().getMasterLists() not yet translated
    // In the full implementation this iterates masterLists.getActiveLists() and
    // copies associations from cdoOld to cdoNew via getCommitStrategy().addToMasterList.
  }

  ListCommitStrategy getCommitStrategy();
}
