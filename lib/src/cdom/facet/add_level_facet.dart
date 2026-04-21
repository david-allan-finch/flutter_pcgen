// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.AddLevelFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/core/settings_handler.dart';
import 'package:flutter_pcgen/src/gui2/ui_property_context.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/template_facet.dart';
import 'player_character_tracking_facet.dart';

/// Applies ADDLEVEL token results when a [PCTemplate] is added/removed.
class AddLevelFacet implements DataFacetChangeListener<CharID, PCTemplate> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late TemplateFacet templateFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, PCTemplate> dfce) {
    final template = dfce.getCDOMObject();
    final id = dfce.getCharID();
    final pc = trackingFacet.getPC(id);
    if (!pc.isImporting()) {
      for (final lcf
          in template.getSafeListFor(ListKey.getConstant('ADD_LEVEL'))) {
        _add(lcf.getLevelCount(), lcf.getPCClass(), pc);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, PCTemplate> dfce) {
    final template = dfce.getCDOMObject();
    final id = dfce.getCharID();
    final pc = trackingFacet.getPC(id);
    final lcfList =
        template.getSafeListFor(ListKey.getConstant('ADD_LEVEL')).toList();
    for (final lcf in lcfList.reversed) {
      _remove(lcf.getLevelCount(), lcf.getPCClass(), pc);
    }
  }

  void _add(dynamic levels, dynamic cl, dynamic pc) {
    _apply(pc, cl, (levels.resolve(pc, '') as num).toInt());
  }

  void _remove(dynamic levels, dynamic cl, dynamic pc) {
    _apply(pc, cl, -(levels.resolve(pc, '') as num).toInt());
  }

  void _apply(dynamic pc, dynamic pcClass, int levels) {
    final tempShowHP = SettingsHandler.getShowHPDialogAtLevelUp();
    SettingsHandler.setShowHPDialogAtLevelUp(false);
    final tempChoicePref = UIPropertyContext.getSingleChoiceAction();
    UIPropertyContext.setSingleChoiceAction(
        UIPropertyContext.chooserSingleChoiceMethodSelectExit);

    pc.incrementClassLevel(levels, pcClass, true, true);

    UIPropertyContext.setSingleChoiceAction(tempChoicePref);
    SettingsHandler.setShowHPDialogAtLevelUp(tempShowHP);
  }

  void init() {
    templateFacet.addDataFacetChangeListener(this);
  }
}
