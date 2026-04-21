//
// Copyright (c) Thomas Parker, 2014.
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
// Translation of pcgen.cdom.facet.input.MasterUsableSkillFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/MasterUsableSkillFacet.java

import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';

/// MasterUsableSkillFacet stores the set of Skills that are usable untrained
/// and not exclusive, as determined from the loaded data set.
class MasterUsableSkillFacet extends AbstractSourcedListFacet<dynamic, dynamic> {
  dynamic dataSetInitializationFacet; // DataSetInitializationFacet

  /// Initializes the facet for the given LoadContext by adding all untrained,
  /// non-exclusive skills.
  void initialize(dynamic context) {
    dynamic id = context.getDataSetID();
    if (getCache(id) == null) {
      for (dynamic sk in context.getReferenceContext().getConstructedCDOMObjects(dynamic)) {
        bool exclusive = sk.getSafeObject(ObjectKey.getConstant('EXCLUSIVE')) ?? false; // ObjectKey.EXCLUSIVE
        bool useUntrained = sk.getSafeObject(ObjectKey.getConstant('USE_UNTRAINED')) ?? false; // ObjectKey.USE_UNTRAINED
        if (!exclusive && useUntrained) {
          add(id, sk, sk);
        }
      }
    }
  }

  void setDataSetInitializationFacet(dynamic dataSetInitializationFacet) {
    this.dataSetInitializationFacet = dataSetInitializationFacet;
  }

  void init() {
    dataSetInitializationFacet?.addDataSetInitializedFacet(this);
  }
}
