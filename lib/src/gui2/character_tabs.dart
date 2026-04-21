//
// Copyright 2009 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.CharacterTabs

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/facade/core/character_facade.dart';
import 'package:flutter_pcgen/src/system/character_manager.dart';
import 'package:flutter_pcgen/src/gui2/tabs/info_tabbed_pane.dart';

/// Tabbed pane for PCGen characters. Manages the set of open characters
/// and notifies the frame and InfoTabbedPane when selection changes.
class CharacterTabs extends StatefulWidget {
  final dynamic frame; // PCGenFrame

  const CharacterTabs({super.key, required this.frame});

  @override
  State<CharacterTabs> createState() => CharacterTabsState();
}

class CharacterTabsState extends State<CharacterTabs>
    with SingleTickerProviderStateMixin {
  final List<CharacterFacade> _characters = [];
  late final TabController _tabController;
  final GlobalKey<InfoTabbedPaneState> _infoPaneKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    CharacterManager.getCharacters().addListListener((_) => _onCharactersChanged());
    widget.frame.getSelectedCharacterRef().addListener(_onSelectedCharacterChanged);
  }

  @override
  void dispose() {
    CharacterManager.getCharacters().removeListListener((_) => _onCharactersChanged());
    widget.frame.getSelectedCharacterRef().removeListener(_onSelectedCharacterChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onCharactersChanged([dynamic _]) {
    final list = CharacterManager.getCharacters();
    setState(() {
      _characters.clear();
      for (int i = 0; i < list.getSize(); i++) {
        _characters.add(list.getElementAt(i));
      }
      _rebuildTabController();
    });
  }

  void _onSelectedCharacterChanged() {
    final selected = widget.frame.getSelectedCharacterRef().get();
    final idx = _characters.indexOf(selected);
    if (idx >= 0 && _tabController.index != idx) {
      _tabController.animateTo(idx);
    }
  }

  void addCharacter(CharacterFacade character) {
    setState(() {
      _characters.add(character);
      _rebuildTabController();
    });
  }

  void removeCharacter(CharacterFacade character) {
    setState(() {
      _characters.remove(character);
      _infoPaneKey.currentState?.characterRemoved(character);
      _rebuildTabController();
    });
  }

  void _rebuildTabController() {
    final oldIndex = _tabController.index;
    _tabController.dispose();
    _tabController = TabController(
      length: _characters.length,
      vsync: this,
      initialIndex: oldIndex.clamp(0, (_characters.length - 1).clamp(0, 999)),
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final idx = _tabController.index;
    final character = idx >= 0 && idx < _characters.length ? _characters[idx] : null;
    widget.frame.setCharacter(character);
    if (character != null) {
      _infoPaneKey.currentState?.setCharacter(character);
    } else {
      _infoPaneKey.currentState?.clearStateMap();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_characters.isEmpty) {
      return Column(
        children: [
          Expanded(child: _buildGuidePane()),
        ],
      );
    }
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _characters.map((c) => _CharacterTabLabel(
            character: c,
            onClose: () => widget.frame.closeCharacter(c),
          )).toList(),
        ),
        Expanded(
          child: InfoTabbedPane(key: _infoPaneKey),
        ),
      ],
    );
  }

  Widget _buildGuidePane() {
    return const Center(
      child: Text('Load sources and create or open a character to begin.'),
    );
  }
}

/// Tab label widget with title and close button.
class _CharacterTabLabel extends StatefulWidget {
  final CharacterFacade character;
  final VoidCallback onClose;

  const _CharacterTabLabel({required this.character, required this.onClose});

  @override
  State<_CharacterTabLabel> createState() => _CharacterTabLabelState();
}

class _CharacterTabLabelState extends State<_CharacterTabLabel> {
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _updateName();
    widget.character.getTabNameRef().addListener(_updateName);
    widget.character.getNameRef().addListener(_updateName);
  }

  @override
  void dispose() {
    widget.character.getTabNameRef().removeListener(_updateName);
    widget.character.getNameRef().removeListener(_updateName);
    super.dispose();
  }

  void _updateName() {
    final tabName = widget.character.getTabNameRef().get();
    final name = widget.character.getNameRef().get();
    setState(() {
      _displayName = (tabName != null && tabName.isNotEmpty) ? tabName : (name ?? '(unnamed)');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_displayName),
        const SizedBox(width: 4),
        InkWell(
          onTap: widget.onClose,
          borderRadius: BorderRadius.circular(8),
          child: const Icon(Icons.close, size: 14),
        ),
      ],
    );
  }
}
