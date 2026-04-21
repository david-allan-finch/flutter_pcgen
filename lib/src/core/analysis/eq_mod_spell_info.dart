//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.analysis.EqModSpellInfo
// Utility methods for extracting spell-related info from equipment modifier strings.
final class EqModSpellInfo {
  static const String sCharges = 'CHARGES';

  EqModSpellInfo._();

  static String getSpellInfoString(String listEntry, String desiredInfo) {
    final offs = listEntry.indexOf('$desiredInfo[');
    final offs2 = listEntry.indexOf(']', offs + 1);
    if (offs >= 0 && offs2 > offs) {
      return listEntry.substring(offs + desiredInfo.length + 1, offs2);
    }
    return '';
  }

  static int getSpellInfo(String listEntry, String desiredInfo) {
    final info = getSpellInfoString(listEntry, desiredInfo);
    if (info.isNotEmpty) {
      try {
        return int.parse(info);
      } catch (_) {}
    }
    return 0;
  }

  static String setSpellInfo(String listEntry, String desiredInfo, String newValue) {
    final offs = listEntry.indexOf('$desiredInfo[');
    if (offs < 0) {
      return '$listEntry|$desiredInfo[$newValue]';
    }
    final offs2 = listEntry.indexOf(']', offs + 1);
    return listEntry.substring(0, offs + desiredInfo.length + 1) +
        newValue +
        listEntry.substring(offs2);
  }
}
