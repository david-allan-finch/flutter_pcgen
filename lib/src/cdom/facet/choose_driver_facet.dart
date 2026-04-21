// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.ChooseDriverFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'domain_selection_facet.dart';
import 'event/scope_facet_change_event.dart';
import 'event/scope_facet_change_listener.dart';
import 'player_character_tracking_facet.dart';
import 'race_selection_facet.dart';
import 'template_selection_facet.dart';

/// Drives application/removal of CHOOSE token selections on CDOMObjects.
class ChooseDriverFacet {
  late PlayerCharacterTrackingFacet trackingFacet;
  late RaceSelectionFacet raceSelectionFacet;
  late DomainSelectionFacet domainSelectionFacet;
  late TemplateSelectionFacet templateSelectionFacet;

  late final _Adder _adder;
  late final _Remover _remover;

  ChooseDriverFacet() {
    _adder = _Adder(this);
    _remover = _Remover(this);
  }

  void init() {
    raceSelectionFacet.addScopeFacetChangeListener(1000, _adder);
    domainSelectionFacet.addScopeFacetChangeListener(1000, _adder);
    templateSelectionFacet.addScopeFacetChangeListener(1000, _adder);
    raceSelectionFacet.addScopeFacetChangeListener(1000, _remover);
    domainSelectionFacet.addScopeFacetChangeListener(1000, _remover);
    templateSelectionFacet.addScopeFacetChangeListener(1000, _remover);
  }
}

class _Adder implements ScopeFacetChangeListener<CharID, dynamic, dynamic> {
  final ChooseDriverFacet _parent;
  _Adder(this._parent);

  @override
  void dataAdded(ScopeFacetChangeEvent<CharID, dynamic, dynamic> dfce) {
    final pc = _parent.trackingFacet.getPC(dfce.getCharID());
    if (!pc.isAllowInteraction()) return;
    final obj = dfce.getScope();
    final sel = dfce.getCDOMObject();
    if (obj.hasNewChooseToken()) {
      obj.getChoiceManager(pc)?.applyChoice(pc, obj, sel);
    }
  }

  @override
  void dataRemoved(ScopeFacetChangeEvent<CharID, dynamic, dynamic> dfce) {
    // ignore
  }
}

class _Remover implements ScopeFacetChangeListener<CharID, dynamic, dynamic> {
  final ChooseDriverFacet _parent;
  _Remover(this._parent);

  @override
  void dataAdded(ScopeFacetChangeEvent<CharID, dynamic, dynamic> dfce) {
    // ignore
  }

  @override
  void dataRemoved(ScopeFacetChangeEvent<CharID, dynamic, dynamic> dfce) {
    final pc = _parent.trackingFacet.getPC(dfce.getCharID());
    if (!pc.isAllowInteraction()) return;
    final assoc = dfce.getCDOMObject();
    final cdo = dfce.getScope();
    if (cdo.hasNewChooseToken()) {
      cdo.getChoiceManager(pc)?.removeChoice(pc, cdo, assoc);
    }
  }
}
