//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.persistence.PersistenceManager
import 'package:flutter_pcgen/src/core/game_mode.dart';
import 'package:flutter_pcgen/src/core/settings_handler.dart';
import 'package:flutter_pcgen/src/persistence/system_loader.dart';

// Singleton factory for accessing the system loader.
final class PersistenceManager {
  PersistenceManager._();
  static final PersistenceManager _instance = PersistenceManager._();
  static PersistenceManager getInstance() => _instance;

  // stub — LstSystemLoader not yet translated
  SystemLoader? _loader; // set externally

  void setChosenCampaignSourcefiles(List<String> l, [GameMode? game]) {
    final g = game ?? SettingsHandler.getGame();
    _loader?.setChosenCampaignSourcefiles(l, g);
  }

  List<String> getChosenCampaignSourcefiles([GameMode? game]) {
    final g = game ?? SettingsHandler.getGame();
    return _loader?.getChosenCampaignSourcefiles(g) ?? [];
  }
}
