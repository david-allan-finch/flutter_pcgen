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
// Translation of pcgen.cdom.facet.input.ClassSkillListFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/ClassSkillListFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_scope_facet.dart';

/// ClassSkillListFacet stores the ClassSkillList choices for a PCClass of a
/// Player Character.
class ClassSkillListFacet extends AbstractScopeFacet<CharID, dynamic, dynamic> {
  dynamic trackingFacet; // PlayerCharacterTrackingFacet
  dynamic classFacet; // ClassFacet
  dynamic defaultClassSkillListFacet; // DefaultClassSkillListFacet
  dynamic subClassFacet; // SubClassFacet
  dynamic skillListFacet; // SkillListFacet

  /// Called when a class level changes.
  void levelChanged(dynamic lce) {
    int oldLevel = lce.getOldLevel();
    int newLevel = lce.getNewLevel();
    if (oldLevel == 0 && newLevel > 0) {
      dynamic cl = lce.getPCClass();
      CharID id = lce.getCharID();
      dynamic csc = cl.get('SKILLLIST_CHOICE'); // ObjectKey.SKILLLIST_CHOICE
      if (csc == null) {
        dynamic l = cl.get('CLASS_SKILLLIST'); // ObjectKey.CLASS_SKILLLIST
        if (l != null) {
          defaultClassSkillListFacet?.add(id, cl, l, cl);
        }
      } else {
        dynamic pc = trackingFacet?.getPC(id);
        for (dynamic st in csc.driveChoice(pc)) {
          add(id, cl, st, cl);
        }
      }
    } else if (oldLevel > 0 && newLevel == 0) {
      removeAllFromSource(lce.getCharID(), lce.getPCClass());
    }
  }

  /// Called when a class level object changes (ignored).
  void levelObjectChanged(dynamic lce) {
    // ignore
  }

  /// Called when a subclass scope data is added.
  void dataAdded(dynamic dfce) {
    dynamic cl = dfce.getScope();
    String subClassKey = dfce.getCDOMObject();
    dynamic subclass = cl.getSubClassKeyed(subClassKey);
    if (subclass != null) {
      dynamic scl = subclass.get('CLASS_SKILLLIST'); // ObjectKey.CLASS_SKILLLIST
      defaultClassSkillListFacet?.add(dfce.getCharID(), cl, scl, subclass);
    }
  }

  /// Called when a subclass scope data is removed.
  void dataRemoved(dynamic dfce) {
    dynamic cl = dfce.getScope();
    String subClassKey = dfce.getCDOMObject();
    dynamic subclass = cl.getSubClassKeyed(subClassKey);
    if (subclass != null) {
      dynamic scl = subclass.get('CLASS_SKILLLIST'); // ObjectKey.CLASS_SKILLLIST
      defaultClassSkillListFacet?.add(dfce.getCharID(), cl, scl, subclass);
    }
  }

  void setClassFacet(dynamic classFacet) {
    this.classFacet = classFacet;
  }

  void setSubClassFacet(dynamic subClassFacet) {
    this.subClassFacet = subClassFacet;
  }

  void setDefaultClassSkillListFacet(dynamic defaultClassSkillListFacet) {
    this.defaultClassSkillListFacet = defaultClassSkillListFacet;
  }

  void setSkillListFacet(dynamic skillListFacet) {
    this.skillListFacet = skillListFacet;
  }

  void init() {
    classFacet?.addLevelChangeListener(this);
    subClassFacet?.addScopeFacetChangeListener(this);
    addScopeFacetChangeListener(skillListFacet);
  }
}
