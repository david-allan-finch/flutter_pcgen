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
// Translation of pcgen.gui2.PCGenMenuBar

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/ui_context.dart';
import 'package:flutter_pcgen/src/gui2/pc_gen_action_map.dart';

/// The menu bar displayed in PCGen's main window.
class PCGenMenuBar extends StatefulWidget {
  final dynamic frame; // PCGenFrame
  final UIContext uiContext;

  const PCGenMenuBar({super.key, required this.frame, required this.uiContext});

  @override
  State<PCGenMenuBar> createState() => _PCGenMenuBarState();
}

class _PCGenMenuBarState extends State<PCGenMenuBar> {
  late final PCGenActionMap _actionMap;

  @override
  void initState() {
    super.initState();
    _actionMap = widget.frame.actionMap as PCGenActionMap;
  }

  void _performAction(String command) {
    _actionMap.get(command)?.perform();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMenu(context, 'File', _buildFileItems(context)),
        _buildMenu(context, 'Edit', _buildEditItems(context)),
        _buildMenu(context, 'Sources', _buildSourcesItems(context)),
        _buildMenu(context, 'Tools', _buildToolsItems(context)),
        _buildMenu(context, 'Help', _buildHelpItems(context)),
      ],
    );
  }

  Widget _buildMenu(BuildContext context, String label, List<PopupMenuEntry<String>> items) {
    return PopupMenuButton<String>(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label),
      ),
      onSelected: _performAction,
      itemBuilder: (_) => items,
    );
  }

  List<PopupMenuEntry<String>> _buildFileItems(BuildContext context) => [
        _item(PCGenActionMap.newCommand, 'New'),
        _item(PCGenActionMap.openCommand, 'Open...'),
        const PopupMenuDivider(),
        _item(PCGenActionMap.closeCommand, 'Close'),
        _item(PCGenActionMap.closeAllCommand, 'Close All'),
        const PopupMenuDivider(),
        _item(PCGenActionMap.saveCommand, 'Save'),
        _item(PCGenActionMap.saveAsCommand, 'Save As...'),
        _item(PCGenActionMap.saveAllCommand, 'Save All'),
        _item(PCGenActionMap.revertCommand, 'Revert to Saved'),
        const PopupMenuDivider(),
        _item(PCGenActionMap.printCommand, 'Print...'),
        _item(PCGenActionMap.exportCommand, 'Export...'),
        const PopupMenuDivider(),
        _item(PCGenActionMap.exitCommand, 'Exit'),
      ];

  List<PopupMenuEntry<String>> _buildEditItems(BuildContext context) => [
        _item(PCGenActionMap.addKitCommand, 'Add Kit'),
        const PopupMenuDivider(),
        _item(PCGenActionMap.tempBonusCommand, 'Temp Bonus'),
      ];

  List<PopupMenuEntry<String>> _buildSourcesItems(BuildContext context) => [
        _item(PCGenActionMap.sourcesLoadSelectCommand, 'Load Sources...'),
        const PopupMenuDivider(),
        _item(PCGenActionMap.sourcesReloadCommand, 'Reload Sources'),
        _item(PCGenActionMap.sourcesUnloadCommand, 'Unload Sources'),
        const PopupMenuDivider(),
        _item(PCGenActionMap.installDataCommand, 'Install Data...'),
      ];

  List<PopupMenuEntry<String>> _buildToolsItems(BuildContext context) => [
        _item(PCGenActionMap.preferencesCommand, 'Preferences...'),
        const PopupMenuDivider(),
        _item(PCGenActionMap.logCommand, 'Log'),
        _item(PCGenActionMap.calculatorCommand, 'Calculator'),
        _item(PCGenActionMap.coreviewCommand, 'Core View'),
        _item(PCGenActionMap.solverviewCommand, 'Solver View'),
      ];

  List<PopupMenuEntry<String>> _buildHelpItems(BuildContext context) => [
        _item(PCGenActionMap.helpDocsCommand, 'Documentation'),
        const PopupMenuDivider(),
        _item(PCGenActionMap.helpOglCommand, 'OGL'),
        _item(PCGenActionMap.helpTipOfTheDayCommand, 'Tip of the Day'),
        const PopupMenuDivider(),
        _item(PCGenActionMap.helpAboutCommand, 'About'),
      ];

  PopupMenuItem<String> _item(String command, String label) {
    final action = _actionMap.get(command);
    return PopupMenuItem<String>(
      value: command,
      enabled: action?.isEnabled ?? true,
      child: Text(label),
    );
  }
}
