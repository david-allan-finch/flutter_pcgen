//
// Copyright 2009 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.rules.context.LoadValidator
import '../../base/util/hash_map_to_list.dart';
import '../../cdom/base/class_identity.dart';
import '../../cdom/reference/qualifier.dart';
import '../../cdom/reference/unconstructed_validator.dart';
import '../../core/campaign.dart';

class LoadValidator implements UnconstructedValidator {
  final List<dynamic> _campaignList; // List<Campaign>
  HashMapToList<String, String>? _simpleMap;

  LoadValidator(List<dynamic> campaigns) : _campaignList = List.of(campaigns);

  @override
  bool allowUnconstructed(ClassIdentity<dynamic> cl, String s) {
    _simpleMap ??= _buildSimpleMap();
    final list = _simpleMap!.getListFor(cl.getPersistentFormat());
    if (list != null) {
      for (final key in list) {
        if (key.toLowerCase() == s.toLowerCase()) {
          return true;
        }
      }
    }
    return false;
  }

  HashMapToList<String, String> _buildSimpleMap() {
    final map = HashMapToList<String, String>();
    for (final c in _campaignList) {
      final forwardRefs = (c as dynamic).getSafeListFor('FORWARDREF') as List;
      for (final q in forwardRefs) {
        final qRef = (q as dynamic).getQualifiedReference();
        map.addToListFor(
          qRef.getPersistentFormat() as String,
          qRef.getLSTformat(false) as String,
        );
      }
    }
    return map;
  }

  @override
  bool allowDuplicates(Type cl) {
    for (final c in _campaignList) {
      if ((c as dynamic).containsInList('DUPES_ALLOWED', cl) == true) {
        return true;
      }
    }
    return false;
  }
}
