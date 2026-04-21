//
// Copyright (c) Thomas Parker, 2012.
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
// Translation of pcgen.cdom.facet.input.TemplateInputFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/TemplateInputFacet.java

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';

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
