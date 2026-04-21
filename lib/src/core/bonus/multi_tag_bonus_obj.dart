//
// Copyright 2003 (C) Greg Bingleman <byngl@hotmail.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.bonus.MultiTagBonusObj
import 'bonus_obj.dart';

// Abstract BonusObj subclass that maps token strings to integer tag indices.
abstract class MultiTagBonusObj extends BonusObj {
  @override
  bool parseToken(dynamic context, String token) {
    for (int i = 0; i < getBonusTagLength(); i++) {
      if (getBonusTag(i) == token) {
        addBonusInfo(i);
        return true;
      }
    }
    if (token.startsWith('TYPE=')) {
      addBonusInfo(token.replaceFirst('=', '.'));
    } else {
      addBonusInfo(token);
    }
    return true;
  }

  @override
  String unparseToken(Object obj) {
    if (obj is int) return getBonusTag(obj);
    return obj as String;
  }

  String getBonusTag(int tagNumber);
  int getBonusTagLength();
}
