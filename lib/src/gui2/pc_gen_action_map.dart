//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.PCGenActionMap

import 'package:flutter_pcgen/src/gui2/ui_context.dart';

typedef ActionCallback = void Function();

/// Holds all actions for PCGen's main menu, toolbar, and popup menus.
/// Actions can be enabled/disabled to update all referencing buttons.
class PCGenAction {
  final String command;
  final String label;
  String? accelerator;
  String? iconKey;
  bool _enabled = true;
  ActionCallback? _handler;

  PCGenAction({
    required this.command,
    required this.label,
    this.accelerator,
    this.iconKey,
    ActionCallback? handler,
  }) : _handler = handler;

  bool get isEnabled => _enabled;
  set isEnabled(bool v) => _enabled = v;

  void perform() {
    if (_enabled) _handler?.call();
  }

  void setHandler(ActionCallback handler) {
    _handler = handler;
  }
}

class PCGenActionMap {
  // File menu commands
  static const String fileCommand = 'file';
  static const String newCommand = 'file.new';
  static const String openCommand = 'file.open';
  static const String openRecentCommand = 'file.openrecent';
  static const String closeCommand = 'file.close';
  static const String closeAllCommand = 'file.closeall';
  static const String saveCommand = 'file.save';
  static const String saveAsCommand = 'file.saveas';
  static const String saveAllCommand = 'file.saveall';
  static const String revertCommand = 'file.reverttosaved';
  static const String partyCommand = 'file.party';
  static const String openPartyCommand = 'file.party.open';
  static const String openRecentPartyCommand = 'file.party.openrecent';
  static const String closePartyCommand = 'file.party.close';
  static const String savePartyCommand = 'file.party.save';
  static const String saveAsPartyCommand = 'file.party.saveas';
  static const String printCommand = 'file.print';
  static const String exportCommand = 'file.export';
  static const String exitCommand = 'file.exit';
  // Edit menu commands
  static const String editCommand = 'edit';
  static const String addKitCommand = 'edit.addkit';
  static const String tempBonusCommand = 'edit.tempbonus';
  static const String equipmentSetCommand = 'edit.equipmentset';
  // Source menu commands
  static const String sourcesCommand = 'sources';
  static const String sourcesLoadCommand = 'sources.load';
  static const String sourcesLoadSelectCommand = 'sources.select';
  static const String sourcesReloadCommand = 'sources.reload';
  static const String sourcesUnloadCommand = 'sources.unload';
  static const String installDataCommand = 'sources.installData';
  // Tools menu commands
  static const String toolsCommand = 'tools';
  static const String preferencesCommand = 'tools.preferences';
  static const String logCommand = 'tools.log';
  static const String loggingLevelCommand = 'tools.loggingLevel';
  static const String calculatorCommand = 'tools.calculator';
  static const String coreviewCommand = 'tools.coreview';
  static const String solverviewCommand = 'tools.solverview';
  // Help menu commands
  static const String helpCommand = 'help';
  static const String helpDocsCommand = 'help.docs';
  static const String helpOglCommand = 'help.ogl';
  static const String helpTipOfTheDayCommand = 'help.tod';
  static const String helpAboutCommand = 'help.about';

  static const String mnuTools = 'mnuTools';
  static const String mnuToolsPreferences = 'mnuToolsPreferences';
  static const String mnuEdit = 'mnuEdit';
  static const String mnuFile = 'mnuFile';

  final Map<String, PCGenAction> _actions = {};
  final dynamic frame; // PCGenFrame — avoid circular import
  final UIContext uiContext;

  PCGenActionMap(this.frame, this.uiContext) {
    _initActions();
  }

  void _initActions() {
    _put(fileCommand, 'File');
    _put(newCommand, 'New', accelerator: 'Ctrl+N', iconKey: 'New16',
        handler: () => frame.createNewCharacter(null));
    _put(openCommand, 'Open', accelerator: 'Ctrl+O', iconKey: 'Open16',
        handler: () => frame.showOpenCharacterChooser());
    _put(openRecentCommand, 'Open Recent');
    _put(closeCommand, 'Close', accelerator: 'Ctrl+W', iconKey: 'Close16',
        handler: () => frame.closeCharacter(frame.getSelectedCharacterRef().get()));
    _put(closeAllCommand, 'Close All', iconKey: 'CloseAll16',
        handler: () => frame.closeAllCharacters());
    _put(saveCommand, 'Save', accelerator: 'Ctrl+S', iconKey: 'Save16',
        handler: () {
          final pc = frame.getSelectedCharacterRef().get();
          if (pc != null) frame.saveCharacter(pc);
        });
    _put(saveAsCommand, 'Save As', accelerator: 'Shift+Ctrl+S', iconKey: 'SaveAs16',
        handler: () => frame.showSaveCharacterChooser(frame.getSelectedCharacterRef().get()));
    _put(saveAllCommand, 'Save All', iconKey: 'SaveAll16',
        handler: () => frame.saveAllCharacters());
    _put(revertCommand, 'Revert to Saved', accelerator: 'Ctrl+R',
        handler: () => frame.revertCharacter(frame.getSelectedCharacterRef().get()));
    _put(partyCommand, 'Party');
    _put(openPartyCommand, 'Open Party', iconKey: 'Open16',
        handler: () => frame.showOpenPartyChooser());
    _put(openRecentPartyCommand, 'Open Recent Party');
    _put(closePartyCommand, 'Close Party', iconKey: 'Close16',
        handler: () => frame.closeAllCharacters());
    _put(savePartyCommand, 'Save Party', iconKey: 'Save16',
        handler: () {
          if (frame.saveAllCharacters()) frame.showSavePartyChooser();
        });
    _put(saveAsPartyCommand, 'Save Party As', iconKey: 'SaveAs16',
        handler: () => frame.showSavePartyChooser());
    _put(printCommand, 'Print', accelerator: 'Ctrl+P', iconKey: 'Print16',
        handler: () => frame.showPrintPreviewDialog());
    _put(exportCommand, 'Export', accelerator: 'Shift+Ctrl+P', iconKey: 'Export16',
        handler: () => frame.showExportDialog());
    _put(exitCommand, 'Exit', accelerator: 'Ctrl+Q',
        handler: () => frame.closePCGen());
    _put(editCommand, 'Edit');
    _put(addKitCommand, 'Add Kit',
        handler: () => frame.showKitSelectionDialog());
    _put(equipmentSetCommand, 'Equipment Set');
    _put(tempBonusCommand, 'Temp Bonus');
    _put(preferencesCommand, 'Preferences', iconKey: 'Preferences16',
        handler: () => frame.displayPreferencesDialog());
    _put(logCommand, 'Log', accelerator: 'F10',
        handler: () => frame.showDebugDialog());
    _put(loggingLevelCommand, 'Logging Level');
    _put(calculatorCommand, 'Calculator', accelerator: 'F11',
        handler: () => frame.showCalculatorDialog());
    _put(coreviewCommand, 'Core View', accelerator: 'Shift+F11',
        handler: () => frame.showCoreViewDialog());
    _put(solverviewCommand, 'Solver View', accelerator: 'Ctrl+F11',
        handler: () => frame.showSolverViewDialog());
    _put(installDataCommand, 'Install Data',
        handler: () => frame.showDataInstallerDialog());
    _put(sourcesLoadSelectCommand, 'Load Sources', accelerator: 'Ctrl+L',
        handler: () => frame.showSourceSelectionDialog());
    _put(sourcesReloadCommand, 'Reload Sources', accelerator: 'Shift+Ctrl+R',
        handler: () => frame.reloadSources());
    _put(sourcesUnloadCommand, 'Unload Sources', accelerator: 'Ctrl+U',
        handler: () => frame.unloadSources());
    _put(helpCommand, 'Help');
    _put(helpDocsCommand, 'Documentation', accelerator: 'F1', iconKey: 'Help16',
        handler: () => frame.showHelpDocs());
    _put(helpOglCommand, 'OGL',
        handler: () => frame.showOGLDialog());
    _put(helpTipOfTheDayCommand, 'Tip of the Day', iconKey: 'TipOfTheDay16',
        handler: () => frame.showTipsOfTheDay());
    _put(helpAboutCommand, 'About', iconKey: 'About16',
        handler: () => frame.showAboutDialog());
  }

  void _put(String key, String label,
      {String? accelerator, String? iconKey, ActionCallback? handler}) {
    _actions[key] = PCGenAction(
      command: key,
      label: label,
      accelerator: accelerator,
      iconKey: iconKey,
      handler: handler,
    );
  }

  PCGenAction? get(String key) => _actions[key];

  void setEnabled(String key, bool enabled) {
    _actions[key]?.isEnabled = enabled;
  }
}
