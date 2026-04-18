// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.UnconditionalTemplateFacet

import '../enumeration/char_id.dart';
import '../../core/pc_template.dart';
import 'base/abstract_list_facet.dart';
import 'model/template_facet.dart';

/// Tracks PCTemplates granted unconditionally to a Player Character.
class UnconditionalTemplateFacet extends AbstractListFacet<CharID, PCTemplate> {
  late TemplateFacet templateFacet;

  void init() {
    addDataFacetChangeListener(templateFacet);
  }
}
