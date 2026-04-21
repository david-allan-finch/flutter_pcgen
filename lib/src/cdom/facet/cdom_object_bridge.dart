// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.CDOMObjectBridge

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'base/abstract_sourced_list_facet.dart';

/// Breaks cycles in the facet graph by acting as the single underlying storage
/// for both [CDOMObjectConsolidationFacet] and [CDOMObjectSourceFacet].
///
/// When objects are added (e.g. Templates), they may trigger addition of more
/// objects of the same type, creating self-referencing cycles. This bridge
/// decouples the two listener facets so cycles can be avoided while sharing the
/// same data store.
final class CDOMObjectBridge
    extends AbstractSourcedListFacet<CharID, CDOMObject> {}
