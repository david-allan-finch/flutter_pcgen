// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.UnconditionalTemplateFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'base/abstract_list_facet.dart';
import 'model/template_facet.dart';

/// Tracks PCTemplates granted unconditionally to a Player Character.
class UnconditionalTemplateFacet extends AbstractListFacet<CharID, PCTemplate> {
  late TemplateFacet templateFacet;

  void init() {
    addDataFacetChangeListener(templateFacet);
  }
}
