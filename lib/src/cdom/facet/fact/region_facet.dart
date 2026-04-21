//
// Copyright (c) Thomas Parker, 2009.
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
// Translation of pcgen.cdom.facet.fact.RegionFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/fact/RegionFacet.java

import '../../../enumeration/char_id.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

/// RegionCacheInfo is the data structure used by RegionFacet to store a
/// Player Character's Region and SubRegion if they are directly set by a user.
class _RegionCacheInfo {
  dynamic cachedRegion; // Optional<Region>
  dynamic region; // Region
  String? subregion;

  @override
  String toString() {
    return '$region $subregion $cachedRegion';
  }

  @override
  int get hashCode => region?.hashCode ?? -1;

  @override
  bool operator ==(Object o) {
    if (o is _RegionCacheInfo) {
      return region == o.region &&
          subregion == o.subregion &&
          cachedRegion == o.cachedRegion;
    }
    return false;
  }
}

/// RegionFacet is a Facet that tracks the Region and SubRegion of a Player
/// Character. The Region and SubRegion can be set explicitly or inferred from
/// the PCTemplate objects possessed by the PlayerCharacter.
class RegionFacet implements DataFacetChangeListener<CharID, dynamic> {
  dynamic templateFacet; // TemplateFacet
  final Map<CharID, dynamic> _cache = {};

  dynamic getCache(CharID id) => _cache[id];
  void setCache(CharID id, dynamic value) => _cache[id] = value;

  _RegionCacheInfo _getConstructingInfo(CharID id) {
    _RegionCacheInfo? rci = _getInfo(id);
    if (rci == null) {
      rci = _RegionCacheInfo();
      setCache(id, rci);
    }
    return rci;
  }

  _RegionCacheInfo? _getInfo(CharID id) {
    return getCache(id) as _RegionCacheInfo?;
  }

  /// Sets the character Region for the Player Character represented by the
  /// given CharID to the given Region.
  void setRegion(CharID id, dynamic region) {
    _getConstructingInfo(id).region = region;
    _updateRegion(id);
  }

  /// Sets the character SubRegion for the Player Character represented by the
  /// given CharID to the given SubRegion.
  void setSubRegion(CharID id, String subregion) {
    _getConstructingInfo(id).subregion = subregion;
  }

  /// Returns the character Region for the Player Character represented by the
  /// given CharID, or null if not set.
  dynamic getCharacterRegion(CharID id) {
    _RegionCacheInfo? rci = _getInfo(id);
    if (rci != null && rci.region != null) {
      return rci.region;
    }
    return null;
  }

  /// Returns the Region for the Player Character represented by the given
  /// CharID, or null if not set.
  dynamic getRegion(CharID id) {
    dynamic charRegion = getCharacterRegion(id);
    return charRegion ?? _getTemplateRegion(id);
  }

  /// Returns a String representation of the Region for the Player Character
  /// represented by the given CharID. Returns "NONE" if no Region is set.
  String getRegionString(CharID id) {
    dynamic charRegion = getCharacterRegion(id);
    dynamic region = charRegion ?? _getTemplateRegion(id);
    return region?.toString() ?? 'NONE';
  }

  dynamic _getTemplateRegion(CharID id) {
    if (templateFacet == null) return null;
    dynamic result;
    for (dynamic template in templateFacet.getSet(id)) {
      dynamic r = template.get('REGION'); // ObjectKey.REGION
      if (r != null) {
        result = r;
      }
    }
    return result;
  }

  /// Returns true if the Region of the Player Character matches the given Region.
  bool matchesRegion(CharID id, dynamic r) {
    dynamic current = getRegion(id) ?? 'NONE';
    dynamic other = r ?? 'NONE';
    return current == other;
  }

  /// Returns the character SubRegion for the Player Character, or null.
  String? getCharacterSubRegion(CharID id) {
    _RegionCacheInfo? rci = _getInfo(id);
    if (rci != null && rci.subregion != null) {
      return rci.subregion;
    }
    return null;
  }

  /// Returns the SubRegion for the Player Character, or null.
  String? getSubRegion(CharID id) {
    _RegionCacheInfo? rci = _getInfo(id);
    if (rci != null && rci.subregion != null) {
      return rci.subregion;
    }
    if (templateFacet == null) return null;
    String? result;
    for (dynamic template in templateFacet.getSet(id)) {
      String? sub = template.get('SUBREGION'); // StringKey.SUBREGION
      if (sub != null) {
        result = sub;
      }
    }
    return result;
  }

  /// Returns a String representation of the full Region (Region and SubRegion).
  String getFullRegion(CharID id) {
    String? sub = getSubRegion(id);
    StringBuffer tempRegName = StringBuffer(getRegionString(id));
    if (sub != null) {
      tempRegName.write(' ($sub)');
    }
    return tempRegName.toString();
  }

  /// Copies the contents of the RegionFacet from one Player Character to another.
  void copyContents(CharID source, CharID destination) {
    _RegionCacheInfo? sourceRCI = _getInfo(source);
    if (sourceRCI != null) {
      _RegionCacheInfo destRCI = _getConstructingInfo(destination);
      destRCI.region = sourceRCI.region;
      destRCI.subregion = sourceRCI.subregion;
    }
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    _updateRegion(dfce.getCharID());
  }

  void _updateRegion(CharID id) {
    _RegionCacheInfo? rci = _getInfo(id);
    if (rci == null) return;
    dynamic current = rci.cachedRegion;
    dynamic newRegion = getRegion(id);
    if (current == null || current != newRegion) {
      // fire DATA_REMOVED for old
      if (current != null) {
        fireDataFacetChangeEvent(id, current.toString(), DataFacetChangeEvent.dataRemoved);
      }
      rci.cachedRegion = newRegion;
      // fire DATA_ADDED for new
      if (newRegion != null) {
        fireDataFacetChangeEvent(id, newRegion.toString(), DataFacetChangeEvent.dataAdded);
      }
    }
  }

  void fireDataFacetChangeEvent(CharID id, dynamic obj, int type) {
    // To be implemented by event infrastructure
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    _updateRegion(dfce.getCharID());
  }

  void setTemplateFacet(dynamic templateFacet) {
    this.templateFacet = templateFacet;
  }
}
