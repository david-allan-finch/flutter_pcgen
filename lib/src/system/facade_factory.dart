// Translation of pcgen.system.FacadeFactory

import '../facade/core/game_mode_display_facade.dart';
import '../facade/core/source_selection_facade.dart';
import '../facade/util/default_list_facade.dart';
import '../facade/util/default_reference_facade.dart';

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
