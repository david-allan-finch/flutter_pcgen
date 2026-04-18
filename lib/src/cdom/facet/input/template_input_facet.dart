// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/TemplateInputFacet.java

import '../../../enumeration/char_id.dart';

/// TemplateInputFacet is a Facet that handles addition of PCTemplates to a
/// Player Character.
class TemplateInputFacet {
  dynamic templateSelectionFacet; // TemplateSelectionFacet
  dynamic unconditionalTemplateFacet; // UnconditionalTemplateFacet
  dynamic trackingFacet; // PlayerCharacterTrackingFacet

  bool add(CharID id, dynamic obj) {
    dynamic pc = trackingFacet?.getPC(id);
    if (pc != null && pc.isAllowInteraction() && _hasNewChooseToken(obj)) {
      dynamic aMan = _getChoiceManager(obj, pc);
      return _processChoice(id, pc, obj, aMan);
    } else {
      directAdd(id, obj, null);
    }
    return true;
  }

  bool _processChoice(CharID id, dynamic pc, dynamic obj, dynamic aMan) {
    List<dynamic> selectedList = [];
    List<dynamic> availableList = [];
    aMan?.getChoices(pc, availableList, selectedList);

    if (availableList.isEmpty) {
      return false;
    }
    if (selectedList.isNotEmpty) {
      print('Selected List is not empty, it contains : ${selectedList.length} templates');
    }
    final List<dynamic> newSelections = aMan?.doChooser(pc, availableList, selectedList, []) ?? [];
    if (newSelections.length != 1) {
      return false;
    }
    for (dynamic sel in newSelections) {
      directAdd(id, obj, sel);
    }
    return true;
  }

  void importSelection(CharID id, dynamic obj, String choice) {
    dynamic pc = trackingFacet?.getPC(id);
    if (_hasNewChooseToken(obj)) {
      dynamic aMan = _getChoiceManager(obj, pc);
      _processImport(id, obj, aMan, choice);
    } else {
      directAdd(id, obj, null);
    }
  }

  void _processImport(CharID id, dynamic obj, dynamic aMan, String choice) {
    directAdd(id, obj, aMan?.decodeChoice(choice));
  }

  void directAdd(CharID id, dynamic obj, dynamic sel) {
    unconditionalTemplateFacet?.add(id, obj);
    if (sel != null) {
      templateSelectionFacet?.set(id, obj, sel);
    }
  }

  void remove(CharID id, dynamic obj) {
    unconditionalTemplateFacet?.remove(id, obj);
    dynamic pc = trackingFacet?.getPC(id);
    if (pc != null && pc.isAllowInteraction()) {
      templateSelectionFacet?.remove(id, obj);
    }
  }

  void setTemplateSelectionFacet(dynamic templateSelectionFacet) {
    this.templateSelectionFacet = templateSelectionFacet;
  }

  void setUnconditionalTemplateFacet(dynamic unconditionalTemplateFacet) {
    this.unconditionalTemplateFacet = unconditionalTemplateFacet;
  }

  // Stubs for Java utility methods
  bool _hasNewChooseToken(dynamic obj) => false;
  dynamic _getChoiceManager(dynamic obj, dynamic pc) => null;
}
