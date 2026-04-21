// Translated from pcgen/rules/context/ConsolidatedListCommitStrategy.java
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net> - LGPL 2.1+

import 'package:flutter_pcgen/src/cdom/base/associated_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_list.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/base/master_list_interface.dart';
import 'package:flutter_pcgen/src/cdom/base/simple_associated_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/association_key.dart';
import 'package:flutter_pcgen/src/rules/context/associated_changes.dart';
import 'package:flutter_pcgen/src/rules/context/associated_collection_changes.dart';
import 'package:flutter_pcgen/src/rules/context/changes.dart';
import 'package:flutter_pcgen/src/rules/context/collection_changes.dart';
import 'package:flutter_pcgen/src/rules/context/list_changes.dart';
import 'package:flutter_pcgen/src/rules/context/list_commit_strategy.dart';

/// ConsolidatedListCommitStrategy implements both [ListCommitStrategy] and
/// [MasterListInterface].  It stores list associations directly on the
/// [CDOMObject] owners rather than in a separate tracking structure, and
/// maintains a single [masterList] for master-list membership.
///
/// This is the "runtime" commit strategy — edits are applied immediately.
class ConsolidatedListCommitStrategy
    implements ListCommitStrategy, MasterListInterface {
  String? _sourceURI;
  String? _extractURI;

  // DoubleKeyMapToList<CDOMReference<list>, CDOMObject, AssociatedPrereqObject>
  //   → Map<CDOMReference, Map<CDOMObject, List<AssociatedPrereqObject>>>
  final Map<CDOMReference<CDOMList<dynamic>>,
          Map<CDOMObject, List<AssociatedPrereqObject>>> _masterList =
      {};

  // ---- URI accessors ----

  String? getExtractURI() => _extractURI;

  @override
  void setExtractURI(String? extractURI) => _extractURI = extractURI;

  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? sourceURI) => _sourceURI = sourceURI;

  // ---- MasterListInterface ----

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
    _masterList
        .putIfAbsent(list, () => {})
        .putIfAbsent(allowed, () => [])
        .add(a);
    return a;
  }

  @override
  void removeFromMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMObject allowed,
  ) {
    _masterList[list]?.remove(allowed);
  }

  @override
  Changes<CDOMReference<dynamic>> getMasterListChanges(
    String tokenName,
    CDOMObject owner,
    Type cl,
  ) {
    final set = <CDOMReference<dynamic>>[];
    outer:
    for (final ref in _masterList.keys) {
      if (ref.getReferenceClass() != cl) continue;
      final byAllowed = _masterList[ref]!;
      for (final allowed in byAllowed.keys) {
        for (final assoc in byAllowed[allowed]!) {
          if (owner == assoc.getAssociation(AssociationKey.owner) &&
              tokenName == assoc.getAssociation(AssociationKey.token)) {
            set.add(ref);
            continue outer;
          }
        }
      }
    }
    return CollectionChanges(set, null, false);
  }

  @override
  void clearAllMasterLists(String tokenName, CDOMObject owner) {
    for (final ref in _masterList.keys) {
      final byAllowed = _masterList[ref]!;
      for (final allowed in byAllowed.keys.toList()) {
        final assocs = byAllowed[allowed]!;
        assocs.removeWhere((assoc) =>
            owner == assoc.getAssociation(AssociationKey.owner) &&
            tokenName == assoc.getAssociation(AssociationKey.token));
      }
    }
  }

  @override
  AssociatedChanges<CDOMObject> getChangesInMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
  ) {
    final added = _masterList[swl]?.keys ?? <CDOMObject>[];
    final owned = <CDOMObject, List<AssociatedPrereqObject>>{};
    for (final lw in added) {
      final list = _masterList[swl]![lw]!;
      final match = list.where(
          (assoc) => owner == assoc.getAssociation(AssociationKey.owner));
      if (match.isNotEmpty) {
        owned.putIfAbsent(lw, () => []).add(match.first);
      }
    }
    return AssociatedCollectionChanges(owned, null, false);
  }

  @override
  bool hasMasterLists() => _masterList.isNotEmpty;

  // ---- ListCommitStrategy — list operations ----

  @override
  AssociatedPrereqObject addToList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMReference<CDOMObject> allowed,
  ) {
    final a = SimpleAssociatedObject();
    a.setAssociation(AssociationKey.token, tokenName);
    owner.putToList(list, allowed, a);
    return a;
  }

  @override
  AssociatedPrereqObject removeFromList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
    CDOMReference<CDOMObject> ref,
  ) {
    owner.removeFromList(swl, ref);
    return SimpleAssociatedObject();
  }

  @override
  void removeAllFromList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<dynamic>> swl,
  ) {
    owner.removeAllFromList(swl as CDOMReference<CDOMList<CDOMObject>>);
  }

  @override
  List<CDOMReference<CDOMList<dynamic>>> getChangedLists(
    CDOMObject owner,
    Type cl,
  ) {
    final list = <CDOMReference<CDOMList<dynamic>>>[];
    for (final ref in owner.getModifiedLists()) {
      if (ref.getReferenceClass() == cl) {
        list.add(ref);
      }
    }
    return list;
  }

  @override
  AssociatedChanges<CDOMReference<CDOMObject>> getChangesInList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
  ) {
    return ListChanges(tokenName, owner, null, swl, false);
  }

  // ---- MasterListInterface — query ----

  @override
  Set<CDOMReference<CDOMList<dynamic>>> getActiveLists() {
    return _masterList.keys.toSet();
  }

  @override
  List<AssociatedPrereqObject>? getAssociationsByRef(
    CDOMReference<CDOMList<CDOMObject>> key1,
    CDOMObject key2,
  ) {
    return _masterList[key1]?[key2];
  }

  @override
  List<AssociatedPrereqObject> getAssociationsByList(
    CDOMList<CDOMObject> key1,
    CDOMObject key2,
  ) {
    final list = <AssociatedPrereqObject>[];
    for (final ref in _masterList.keys) {
      if (ref.contains(key1)) {
        final tempList = _masterList[ref]?[key2];
        if (tempList != null) {
          list.addAll(tempList);
        }
      }
    }
    return list;
  }

  @override
  bool equalsTracking(ListCommitStrategy commit) => false;

  @override
  List<CDOMObject> getObjects(CDOMReference<CDOMList<CDOMObject>> ref) {
    return _masterList[ref]?.keys.toList() ?? [];
  }
}
