// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.UIDelegate

import 'chooser_facade.dart';
import 'equipment_builder_facade.dart';
import 'spell_builder_facade.dart';

enum CustomEquipResult { complete, cancelled }

abstract interface class UIDelegate {
  bool showWarningConfirm(String title, String message);
  void showWarningMessage(String title, String message);
  void showErrorMessage(String title, String message);
  void showInfoMessage(String title, String message);
  void showLevelUpInfo(dynamic character, int oldLevel);
  bool showGeneralChooser(ChooserFacade chooserFacade);
  CustomEquipResult showCustomEquipDialog(
      dynamic character, EquipmentBuilderFacade equipBuilder);
  bool showCustomSpellDialog(SpellBuilderFacade spellBuilderFacade);
}
