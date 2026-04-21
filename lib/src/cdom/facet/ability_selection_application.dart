// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.cdom.facet.AbilitySelectionApplication

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/helper/cn_ability_selection.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'player_character_tracking_facet.dart';

/// Applies/removes ability choice selections when CNAbilitySelection objects
/// are added to or removed from a Player Character.
class AbilitySelectionApplication
    implements DataFacetChangeListener<CharID, CNAbilitySelection> {
  late PlayerCharacterTrackingFacet pcFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CNAbilitySelection> dfce) {
    final id = dfce.getCharID();
    final pc = pcFacet.getPC(id);
    final cnas = dfce.getCDOMObject();
    final cna = cnas.getCNAbility();
    final ability = cna.getAbility();
    final selection = cnas.getSelection();
    if (selection != null) {
      final chooseInfo =
          ability.get(ObjectKey.getConstant<dynamic>('CHOOSE_INFO'));
      if (chooseInfo != null) {
        _applySelection(pc, chooseInfo, cna, selection);
      }
    }
  }

  void _applySelection(dynamic pc, dynamic chooseInfo, dynamic cna, String selection) {
    // TODO: Requires Globals.getContext() for chooseInfo.decodeChoice()
    final obj = chooseInfo.decodeChoice(null, selection);
    if (obj == null) {
      // Log error: selection does not exist in loaded data
    } else {
      chooseInfo.getChoiceActor().applyChoice(cna, obj, pc);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CNAbilitySelection> dfce) {
    final id = dfce.getCharID();
    final cnas = dfce.getCDOMObject();
    final pc = pcFacet.getPC(id);
    final cna = cnas.getCNAbility();
    final ability = cna.getAbility();
    final selection = cnas.getSelection();
    if (selection != null) {
      final chooseInfo =
          ability.get(ObjectKey.getConstant<dynamic>('CHOOSE_INFO'));
      if (chooseInfo != null) {
        _removeSelection(pc, chooseInfo, cna, selection);
      }
    }
  }

  void _removeSelection(dynamic pc, dynamic chooseInfo, dynamic cna, String selection) {
    // TODO: Requires Globals.getContext() for chooseInfo.decodeChoice()
    final obj = chooseInfo.decodeChoice(null, selection);
    chooseInfo.getChoiceActor().removeChoice(pc, cna, obj);
  }
}
