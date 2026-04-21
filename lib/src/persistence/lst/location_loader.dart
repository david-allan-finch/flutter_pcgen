//
// Copyright 2003 (C) David Hibbs <sage_sam@users.sourceforge.net>
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
//
// Translation of pcgen.persistence.lst.LocationLoader

import '../../core/system_collections.dart';
import 'lst_line_file_loader.dart';

/// Loads location/birthplace/city lists from location .lst files.
///
/// The file is section-based: a [LOCATION], [BIRTHPLACE], or [CITY] header
/// sets the current section; plain lines are added to the current list.
class LocationLoader extends LstLineFileLoader {
  int _traitType = -1;
  String _gameMode = '';

  void setGameMode(String gameMode) => _gameMode = gameMode;

  @override
  Future<void> loadLstFile(dynamic context, Uri source) async {
    _traitType = -1;
    await super.loadLstFile(context, source);
  }

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    if (!lstLine.startsWith('[')) {
      switch (_traitType) {
        case 0:
          SystemCollections.addToLocationList(lstLine.trim(), _gameMode);
        case 1:
          SystemCollections.addToBirthplaceList(lstLine.trim(), _gameMode);
        case 2:
          SystemCollections.addToCityList(lstLine.trim(), _gameMode);
        default:
          break;
      }
    } else {
      if (lstLine.startsWith('[LOCATION]')) {
        _traitType = 0;
      } else if (lstLine.startsWith('[BIRTHPLACE]')) {
        _traitType = 1;
      } else if (lstLine.startsWith('[CITY]')) {
        _traitType = 2;
      }
    }
  }
}
