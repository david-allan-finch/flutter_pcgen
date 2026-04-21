// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';

// stub: OutputDB.register("weaponprofs", this)
// dynamic: WeaponProf, Equipment, WeaponProfFacet, AutoWeaponProfFacet,
//           HasDeityWeaponProfFacet, DeityWeaponProfFacet (not yet translated)

/// WeaponProfModelFacet tracks the WeaponProfs that have been granted to a
/// Player Character. Aggregates weapon profs from multiple sources.
class WeaponProfModelFacet {
  // @Autowired - stub
  dynamic weaponProfFacet;
  dynamic autoWeaponProfFacet;
  dynamic hasDeityWeaponProfFacet;
  dynamic deityWeaponProfFacet;

  /// Returns a Set of all WeaponProfs for the given CharID.
  Set<dynamic> getSet(CharID id) {
    final ret = <dynamic>{};
    // stub: ret.addAll(weaponProfFacet.getSet(id));
    // stub: ret.addAll(autoWeaponProfFacet.getWeaponProfs(id));
    // stub: if (hasDeityWeaponProfFacet.hasDeityWeaponProf(id)) ret.addAll(deityWeaponProfFacet.getSet(id));
    return ret;
  }

  /// Returns true if the Player Character has the given WeaponProf.
  bool containsProf(CharID id, dynamic wp) {
    // stub: weaponProfFacet.contains(id, wp)
    //        || autoWeaponProfFacet.containsProf(id, wp)
    //        || (hasDeityWeaponProfFacet.hasDeityWeaponProf(id) && deityWeaponProfFacet.getSet(id).contains(wp))
    return false;
  }

  /// Returns true if the Player Character is proficient with the given weapon.
  bool isProficientWithWeapon(CharID id, dynamic eq) {
    // stub: if (eq.isNatural()) return true;
    // stub: CDOMSingleRef<WeaponProf> ref = eq.getObject(ObjectKey.WEAPON_PROF); if (ref == null) return false;
    // stub: return containsProf(id, ref.get());
    return false;
  }

  int getCount(CharID id) => getSet(id).length;

  void setWeaponProfFacet(dynamic f) => weaponProfFacet = f;
  void setAutoWeaponProfFacet(dynamic f) => autoWeaponProfFacet = f;
  void setHasDeityWeaponProfFacet(dynamic f) => hasDeityWeaponProfFacet = f;
  void setDeityWeaponProfFacet(dynamic f) => deityWeaponProfFacet = f;

  void init() {
    // stub: OutputDB.register("weaponprofs", this)
  }
}
