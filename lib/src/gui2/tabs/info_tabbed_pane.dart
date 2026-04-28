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
// Translation of pcgen.gui2.tabs.InfoTabbedPane

import 'package:flutter/material.dart';

import 'package:flutter_pcgen/src/gui2/tabs/character_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/tab_title.dart';
import 'package:flutter_pcgen/src/gui2/tabs/todo_handler.dart';
import 'package:flutter_pcgen/src/gui2/tabs/abilities_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/character_sheet_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/class_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/companion_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/description_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/domain_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/equip_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/inventory_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/purchase_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/race_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/skill_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/spells_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/summary_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/temp_bonus_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/template_info_tab.dart';

/// Tab index constants matching the Java originals.
class InfoTabbedPaneIndex {
  static const int summary = 0;
  static const int race = 1;
  static const int template = 2;
  static const int classTab = 3;
  static const int skill = 4;
  static const int abilities = 5;
  static const int domain = 6;
  static const int spells = 7;
  static const int inventory = 8;
  static const int description = 9;
  static const int characterSheet = 10;
}

/// Holds the per-character state for the tabbed pane: which models have been
/// created and which tab was selected.
class _CharacterState {
  final Map<Type, ModelMap> modelsByTab;
  int selectedIndex;

  _CharacterState({required this.modelsByTab, this.selectedIndex = 0});
}

/// The main tabbed pane that contains all [CharacterInfoTab]s and manages
/// per-character model caches. Equivalent to [InfoTabbedPane] in Java.
class InfoTabbedPane extends StatefulWidget {
  const InfoTabbedPane({super.key});

  @override
  State<InfoTabbedPane> createState() => InfoTabbedPaneState();
}

class InfoTabbedPaneState extends State<InfoTabbedPane>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Ordered list of tab widget factories.
  final List<_TabEntry> _tabs = [];

  // Per-character model caches: characterId -> state.
  final Map<Object, _CharacterState> _stateMap = {};
  dynamic _currentCharacter;

  @override
  void initState() {
    super.initState();
    _buildTabList();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _buildTabList() {
    _tabs.addAll([
      _TabEntry(label: 'Summary',     type: SummaryInfoTabWidget, builder: () => const SummaryInfoTabWidget()),
      _TabEntry(label: 'Race',        type: RaceInfoTab,          builder: () => const RaceInfoTab()),
      _TabEntry(label: 'Templates',   type: TemplateInfoTab,      builder: () => const TemplateInfoTab()),
      _TabEntry(label: 'Class',       type: ClassInfoTab,         builder: () => const ClassInfoTab()),
      _TabEntry(label: 'Skills',      type: SkillInfoTab,         builder: () => const SkillInfoTab()),
      _TabEntry(label: 'Feats',       type: AbilitiesInfoTab,     builder: () => const AbilitiesInfoTab()),
      _TabEntry(label: 'Domains',     type: DomainInfoTab,        builder: () => const DomainInfoTab()),
      _TabEntry(label: 'Spells',      type: SpellsInfoTab,        builder: () => const SpellsInfoTab()),
      _TabEntry(label: 'Inventory',   type: InventoryInfoTab,     builder: () => const InventoryInfoTab()),
      _TabEntry(label: 'Description', type: DescriptionInfoTab,   builder: () => const DescriptionInfoTab()),
      _TabEntry(label: 'Temp Bonus',  type: TempBonusInfoTab,     builder: () => const TempBonusInfoTab()),
      _TabEntry(label: 'Companions',  type: CompanionInfoTab,     builder: () => const CompanionInfoTab()),
      _TabEntry(label: 'Sheet',       type: CharacterSheetInfoTab,builder: () => const CharacterSheetInfoTab()),
    ]);
  }

  void _onTabChanged() {
    // Notify the currently displayed tab if it supports display-awareness.
    // In the full implementation this would call tabSelected() on DisplayAwareTab.
  }

  /// Switch to the character [character]. Saves models for the current character
  /// and restores (or creates) models for the new one.
  void setCharacter(dynamic character) {
    if (character == null) return;

    final characterKey = character as Object;

    if (!_stateMap.containsKey(characterKey)) {
      // First time seeing this character — create models for every tab.
      final tabModels = <Type, ModelMap>{};
      for (final entry in _tabs) {
        // In a full implementation each tab widget would implement
        // CharacterInfoTab and createModels would be called here.
        tabModels[entry.type] = ModelMap();
      }
      _stateMap[characterKey] = _CharacterState(modelsByTab: tabModels);
    }

    // Save tab selection for the previous character.
    if (_currentCharacter != null) {
      final prevKey = _currentCharacter as Object;
      if (_stateMap.containsKey(prevKey)) {
        _stateMap[prevKey]!.selectedIndex = _tabController.index;
      }
    }

    _currentCharacter = character;

    // Restore the tab that was active when this character was last viewed.
    final state = _stateMap[characterKey]!;
    final targetIndex = state.selectedIndex.clamp(0, _tabs.length - 1);
    if (_tabController.index != targetIndex) {
      _tabController.animateTo(targetIndex);
    }

    setState(() {});
  }

  /// Remove cached state for [character] when the character sheet is closed.
  void characterRemoved(dynamic character) {
    if (character != null) {
      _stateMap.remove(character as Object);
    }
  }

  /// Clear all cached model state (e.g. when closing all characters).
  void clearStateMap() {
    _stateMap.clear();
    _currentCharacter = null;
    setState(() {});
  }

  /// Switch to the tab specified in [dest] and optionally advise a todo field.
  ///
  /// [dest] mirrors the Java `dest` array: `[tabName, fieldName, subTabName?]`.
  void switchTabsAndAdviseTodo(List<String> dest) {
    if (dest.isEmpty) return;
    final tabName = dest[0];
    final fieldName = dest.length > 1 ? dest[1] : '';

    // Find the tab by name.
    for (int i = 0; i < _tabs.length; i++) {
      final label = _tabs[i].label;
      if (label == tabName) {
        _tabController.animateTo(i);
        // If the widget implements TodoHandler, call adviseTodo.
        // (Handled in the build tree via GlobalKey lookups in a full impl.)
        break;
      }
    }
    // Fallback: show a SnackBar when the tab cannot handle the advice itself.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action required in field: $fieldName')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs
              .map((e) => Tab(text: e.label))
              .toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tabs.map((e) => e.builder()).toList(),
          ),
        ),
      ],
    );
  }
}

class _TabEntry {
  final Type type;
  final Widget Function() builder;
  String label;

  _TabEntry({required this.type, required this.builder, String? label})
      : label = label ?? type.toString().replaceAll('Widget', '');
}
