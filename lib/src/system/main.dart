//
// Copyright 2009 Connor Petty <cpmeister@users.sourceforge.net>
// Copyright 2019 Timothy Reaves <treaves@silverfieldstech.com>
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
// Translation of pcgen.system.Main

import 'package:flutter_pcgen/src/pluginmgr/plugin_manager.dart';
import 'package:flutter_pcgen/src/system/character_manager.dart';
import 'package:flutter_pcgen/src/system/configuration_settings.dart';
import 'package:flutter_pcgen/src/system/facade_factory.dart';

/// Application entry point and initialization logic.
final class Main {
  Main._();

  /// Initialize PCGen subsystems. Call once at startup.
  static void startup() {
    ConfigurationSettings.getInstance();
    FacadeFactory._();
    CharacterManager._();
    PluginManager.getInstance();
    // TODO: load game data, LST tokens, etc.
  }

  /// Shutdown PCGen subsystems cleanly.
  static void shutdown() {
    // TODO: save settings, close characters, etc.
  }
}
