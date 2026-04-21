// Copyright (c) Tom Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.MovementResultFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_storage_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/bonus_checking_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/equipment_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/formula_resolving_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';
import 'base_movement_facet.dart';
import 'load_facet.dart';
import 'move_clone_facet.dart';
import 'movement_facet.dart';
import 'unencumbered_armor_facet.dart';
import 'unencumbered_load_facet.dart';

/// Stores the resulting aggregated movement for a Player Character.
class MovementResultFacet extends AbstractStorageFacet<CharID> {
  late MovementFacet movementFacet;
  late MoveCloneFacet moveCloneFacet;
  late BaseMovementFacet baseMovementFacet;
  late RaceFacet raceFacet;
  late TemplateFacet templateFacet;
  late EquipmentFacet equipmentFacet;
  late BonusCheckingFacet bonusCheckingFacet;
  late UnencumberedArmorFacet unencumberedArmorFacet;
  late UnencumberedLoadFacet unencumberedLoadFacet;
  late FormulaResolvingFacet formulaResolvingFacet;
  late LoadFacet loadFacet;

  /// Returns the movement value (in feet) for the given movement type.
  double getMovement(CharID id, String movementType) {
    // TODO: Full implementation requires aggregating base movement, bonuses,
    // equipment encumbrance, and move-clone multipliers.
    return 0.0;
  }

  /// Returns the count of movement types for the Player Character.
  int getMovementTypeCount(CharID id) {
    // TODO: Derive from cached movement map.
    return 0;
  }

  /// Returns the name of the movement type at the given index.
  String getMovementType(CharID id, int index) {
    // TODO: Derive from cached movement map.
    return '';
  }

  @override
  void copyContents(CharID source, CharID copy) {
    // TODO: Copy cached movement map.
  }
}
