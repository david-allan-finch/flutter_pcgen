// Copyright (c) James Dempsey, 2012.
//
// Translation of pcgen.cdom.facet.CategorizedDataFacetChangeEvent

import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/nature.dart';
import 'event/data_facet_change_event.dart';

/// A DataFacetChangeEvent that also carries the category and nature of the change.
/// Typically used for Ability add/remove events.
class CategorizedDataFacetChangeEvent<IDT, T> extends DataFacetChangeEvent<IDT, T> {
  final Category category;
  final Nature nature;

  CategorizedDataFacetChangeEvent(
    super.id,
    super.cdo,
    super.source,
    super.type,
    this.category,
    this.nature,
  );
}
