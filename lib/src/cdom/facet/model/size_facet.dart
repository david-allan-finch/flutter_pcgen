// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_data_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

// stub: TemplateFacet, RaceFacet, FormulaResolvingFacet, BonusCheckingFacet,
//        LevelFacet, ResultFacet, CDOMObjectConsolidationFacet wiring
// stub: OutputDB.register("sizeadjustment", this)
// dynamic: SizeAdjustment, Race, PCTemplate (not yet translated)
// dynamic: BonusChangeEvent, BonusChangeListener, LevelChangeEvent, LevelChangeListener

/// SizeFacet tracks the SizeAdjustment for a Player Character.
class SizeFacet extends AbstractDataFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {
  // @Autowired - stub
  dynamic templateFacet;
  dynamic raceFacet;
  dynamic formulaResolvingFacet;
  dynamic bonusCheckingFacet;
  dynamic levelFacet;
  dynamic resultFacet;
  dynamic consolidationFacet;
  dynamic loadContextFacet; // stub: FacetLibrary.getFacet(LoadContextFacet.class)

  /// Returns the integer indicating the racial size for the Player Character.
  int racialSizeInt(CharID id) {
    // stub: check CControl.BASESIZE via loadContextFacet/resultFacet
    final info = _getInfo(id);
    if (info == null) {
      // stub: return SizeUtilities.getDefaultSizeAdjustment().get(IntegerKey.SIZEORDER)
      return 0;
    }
    return info.racialSizeInt;
  }

  int _calcRacialSizeInt(CharID id) {
    // stub: check CControl.BASESIZE
    final info = _getConstructingInfo(id);
    // stub: compute iSize from race, templates, formulaResolvingFacet
    info.racialSizeInt = 0;
    return 0;
  }

  /// Forces a complete update of the size information for the given CharID.
  void update(CharID id) {
    final info = _getConstructingInfo(id);
    // stub: full size calculation via bonusCheckingFacet, sizesToAdvance, Globals
    final iSize = _calcRacialSizeInt(id);
    final oldSize = info.sizeAdj;
    // stub: newSize = Globals.getContext().getReferenceContext()...get(iSize)
    final dynamic newSize = null;
    info.sizeAdj = newSize;
    if (oldSize != newSize) {
      if (oldSize != null) {
        fireDataFacetChangeEvent(id, oldSize, DataFacetChangeEvent.dataRemoved);
      }
      if (newSize != null) {
        fireDataFacetChangeEvent(id, newSize, DataFacetChangeEvent.dataAdded);
      }
    }
  }

  int _sizesToAdvanceForChar(CharID id, dynamic race) {
    // stub: levelFacet.getMonsterLevelCount(id)
    return sizesToAdvance(race, 0);
  }

  int sizesToAdvance(dynamic race, int monsterLevelCount) {
    // stub: race.getListFor(ListKey.HITDICE_ADVANCEMENT)
    return 0;
  }

  /// Returns the SizeAdjustment active for the given CharID.
  dynamic get(CharID id) {
    final info = _getInfo(id);
    // stub: return SizeUtilities.getDefaultSizeAdjustment() if info == null
    return info?.sizeAdj;
  }

  /// Returns the key name (abbreviation) of the active SizeAdjustment.
  String getSizeAbb(CharID id) {
    final sa = get(id);
    // stub: return sa.getKeyName()
    return sa?.toString() ?? '';
  }

  SizeFacetInfo _getConstructingInfo(CharID id) {
    SizeFacetInfo? rci = _getInfo(id);
    if (rci == null) {
      rci = SizeFacetInfo();
      setCache(id, rci);
    }
    return rci;
  }

  SizeFacetInfo? _getInfo(CharID id) {
    return getCache(id) as SizeFacetInfo?;
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    update(dfce.getCharID());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    update(dfce.getCharID());
  }

  // stub: levelChanged(LevelChangeEvent lce) { update(lce.getCharID()); }
  // stub: bonusChange(BonusChangeEvent bce) { update(bce.getCharID()); }

  void setTemplateFacet(dynamic f) => templateFacet = f;
  void setRaceFacet(dynamic f) => raceFacet = f;
  void setFormulaResolvingFacet(dynamic f) => formulaResolvingFacet = f;
  void setBonusCheckingFacet(dynamic f) => bonusCheckingFacet = f;
  void setLevelFacet(dynamic f) => levelFacet = f;
  void setResultFacet(dynamic f) => resultFacet = f;
  void setConsolidationFacet(dynamic f) => consolidationFacet = f;

  void init() {
    // stub: consolidationFacet.addDataFacetChangeListener(this)
    // stub: OutputDB.register("sizeadjustment", this)
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final si = _getInfo(source);
    if (si != null) {
      final copysfi = _getConstructingInfo(copy);
      copysfi.racialSizeInt = si.racialSizeInt;
      copysfi.sizeAdj = si.sizeAdj;
    }
  }
}

/// Internal data structure holding size information for a Player Character.
class SizeFacetInfo {
  int racialSizeInt = 0;
  dynamic sizeAdj;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    if (o is SizeFacetInfo) {
      return racialSizeInt == o.racialSizeInt && sizeAdj == o.sizeAdj;
    }
    return false;
  }

  @override
  int get hashCode => (sizeAdj?.hashCode ?? 0) ^ (racialSizeInt * 29);
}
