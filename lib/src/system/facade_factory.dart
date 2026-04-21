//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.system.FacadeFactory

import 'package:flutter_pcgen/src/facade/core/game_mode_display_facade.dart';
import 'package:flutter_pcgen/src/facade/core/source_selection_facade.dart';
import 'package:flutter_pcgen/src/facade/util/default_list_facade.dart';
import 'package:flutter_pcgen/src/facade/util/default_reference_facade.dart';

/// Factory providing access to game-mode and source-selection facades.
final class FacadeFactory {
  static final DefaultListFacade<GameModeDisplayFacade> _gameModes =
      DefaultListFacade();
  static final DefaultListFacade<SourceSelectionFacade> _sources =
      DefaultListFacade();
  static final DefaultReferenceFacade<SourceSelectionFacade?> _currentSourceSelection =
      DefaultReferenceFacade(null);

  FacadeFactory._();

  static DefaultListFacade<GameModeDisplayFacade> getGameModes() => _gameModes;

  static DefaultListFacade<SourceSelectionFacade> getSources() => _sources;

  static DefaultReferenceFacade<SourceSelectionFacade?> getCurrentSourceSelection() =>
      _currentSourceSelection;

  static void setCurrentSourceSelection(SourceSelectionFacade? selection) =>
      _currentSourceSelection.set(selection);

  static void reset() {
    _gameModes.clearContents();
    _sources.clearContents();
    _currentSourceSelection.set(null);
  }
}
