// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/RaceInputFacet.java

import '../../../enumeration/char_id.dart';

/// RaceInputFacet is a Facet that tracks the Race of a Player Character.
class RaceInputFacet {
  dynamic trackingFacet; // PlayerCharacterTrackingFacet
  dynamic raceSelectionFacet; // RaceSelectionFacet
  dynamic raceFacet; // RaceFacet

  bool set(CharID id, dynamic race) {
    dynamic pc = trackingFacet?.getPC(id);
    if (pc != null && pc.isAllowInteraction() && _hasNewChooseToken(race)) {
      dynamic aMan = _getChoiceManager(race, pc);
      return _processChoice(id, pc, race, aMan);
    } else {
      return directSet(id, race, null);
    }
  }

  bool _processChoice(CharID id, dynamic pc, dynamic race, dynamic aMan) {
    List<dynamic> selectedList = [];
    List<dynamic> availableList = [];
    aMan?.getChoices(pc, availableList, selectedList);

    if (availableList.isEmpty) {
      return false;
    }
    if (selectedList.isNotEmpty) {
      print('Selected List is not empty, it contains : ${selectedList.length} races');
    }
    final List<dynamic> newSelections = aMan?.doChooser(pc, availableList, selectedList, []) ?? [];
    if (newSelections.length != 1) {
      return false;
    }
    for (dynamic sel in newSelections) {
      directSet(id, race, sel);
    }
    return true;
  }

  void importSelection(CharID id, dynamic race, String choice) {
    dynamic pc = trackingFacet?.getPC(id);
    if (_hasNewChooseToken(race)) {
      dynamic aMan = _getChoiceManager(race, pc);
      _processImport(id, race, aMan, choice);
    } else {
      directSet(id, race, null);
    }
  }

  void _processImport(CharID id, dynamic race, dynamic aMan, String choice) {
    directSet(id, race, aMan?.decodeChoice(choice));
  }

  bool directSet(CharID id, dynamic race, dynamic sel) {
    dynamic old = raceFacet?.get(id);
    bool changed = raceFacet?.set(id, race) ?? false;
    if (changed && old != null) {
      dynamic pc = trackingFacet?.getPC(id);
      if (pc != null && pc.isAllowInteraction()) {
        raceSelectionFacet?.remove(id, old);
      }
    }
    if (sel != null) {
      raceSelectionFacet?.set(id, race, sel);
    }
    return true;
  }

  void remove(CharID id) {
    dynamic r = raceFacet?.remove(id);
    dynamic pc = trackingFacet?.getPC(id);
    if (pc != null && pc.isAllowInteraction() && r != null) {
      raceSelectionFacet?.remove(id, r);
    }
  }

  void setRaceSelectionFacet(dynamic raceSelectionFacet) {
    this.raceSelectionFacet = raceSelectionFacet;
  }

  void setRaceFacet(dynamic raceFacet) {
    this.raceFacet = raceFacet;
  }

  // Stubs for Java utility methods
  bool _hasNewChooseToken(dynamic obj) => false;
  dynamic _getChoiceManager(dynamic obj, dynamic pc) => null;
}
