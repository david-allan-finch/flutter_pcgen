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
// Translation of pcgen.cdom.facet.input.DomainInputFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/DomainInputFacet.java

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';

/// DomainInputFacet is a Facet that handles addition of Domains to a Player
/// Character.
class DomainInputFacet {
  dynamic domainFacet; // DomainFacet
  dynamic domainSelectionFacet; // DomainSelectionFacet
  dynamic trackingFacet; // PlayerCharacterTrackingFacet

  bool add(CharID id, dynamic obj, dynamic source) {
    dynamic pc = trackingFacet?.getPC(id);
    if (pc != null && pc.isAllowInteraction() && _hasNewChooseToken(obj)) {
      dynamic aMan = _getChoiceManager(obj, pc);
      return _processChoice(id, pc, obj, aMan, source);
    } else {
      directSet(id, obj, null, source);
    }
    return true;
  }

  bool _processChoice(CharID id, dynamic pc, dynamic obj, dynamic aMan, dynamic source) {
    List<dynamic> selectedList = [];
    List<dynamic> availableList = [];
    aMan?.getChoices(pc, availableList, selectedList);

    if (availableList.isEmpty) {
      return false;
    }
    if (selectedList.isNotEmpty) {
      print('Selected List is not empty, it contains : ${selectedList.length} domains');
    }
    final List<dynamic> newSelections = aMan?.doChooser(pc, availableList, selectedList, []) ?? [];
    if (newSelections.length != 1) {
      return false;
    }
    for (dynamic sel in newSelections) {
      directSet(id, obj, sel, source);
    }
    return true;
  }

  void importSelection(CharID id, dynamic obj, String choice, dynamic source) {
    dynamic pc = trackingFacet?.getPC(id);
    if (_hasNewChooseToken(obj)) {
      dynamic aMan = _getChoiceManager(obj, pc);
      List<String> assoc = choice.split(',');
      for (String string in assoc) {
        String s = string;
        if (s.startsWith('FEAT?')) {
          int openloc = s.indexOf('(');
          int closeloc = s.lastIndexOf(')');
          s = s.substring(openloc + 1, closeloc);
        }
        _processImport(id, obj, aMan, s, source);
      }
    } else {
      directSet(id, obj, null, source);
    }
  }

  void _processImport(CharID id, dynamic obj, dynamic aMan, String choice, dynamic source) {
    directSet(id, obj, aMan?.decodeChoice(choice), source);
  }

  void directSet(CharID id, dynamic obj, dynamic sel, dynamic source) {
    domainFacet?.add(id, obj, source);
    if (sel != null) {
      domainSelectionFacet?.set(id, obj, sel);
    }
  }

  void remove(CharID id, dynamic obj) {
    dynamic pc = trackingFacet?.getPC(id);
    if (pc != null && pc.isAllowInteraction()) {
      domainSelectionFacet?.remove(id, obj);
    }
    domainFacet?.remove(id, obj);
  }

  void setDomainSelectionFacet(dynamic domainSelectionFacet) {
    this.domainSelectionFacet = domainSelectionFacet;
  }

  void setDomainFacet(dynamic domainFacet) {
    this.domainFacet = domainFacet;
  }

  // Stubs for Java utility methods
  bool _hasNewChooseToken(dynamic obj) => false;
  dynamic _getChoiceManager(dynamic obj, dynamic pc) => null;
}
