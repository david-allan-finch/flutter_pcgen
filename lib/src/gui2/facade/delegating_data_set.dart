//
// Copyright 2014 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.facade.DelegatingDataSet

import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/core/body_structure.dart';
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/deity.dart';
import 'package:flutter_pcgen/src/core/game_mode.dart';
import 'package:flutter_pcgen/src/core/kit.dart';
import 'package:flutter_pcgen/src/core/pc_alignment.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/core/race.dart';
import 'package:flutter_pcgen/src/core/size_adjustment.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/facade/core/ability_facade.dart';
import 'package:flutter_pcgen/src/facade/core/data_set_facade.dart';
import 'package:flutter_pcgen/src/facade/core/equipment_facade.dart';
import 'package:flutter_pcgen/src/facade/core/gear_buy_sell_facade.dart';
import 'package:flutter_pcgen/src/facade/util/delegating_list_facade.dart';
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';
import 'package:flutter_pcgen/src/facade/util/map_facade.dart';

/// Implements DataSetFacade by delegating to another DataSetFacade.
///
/// This class is the DataSetFacade returned by CharacterFacadeImpl and is
/// necessary to protect outside event listeners from directly listening to the
/// real DataSetFacade. By adding this delegate layer, upon closing a character,
/// the CFI can sever connections between this and the actual DataSetFacade,
/// preventing memory leaks.
class DelegatingDataSet implements DataSetFacade {
  final DelegatingListFacade<Race> _races;
  final DelegatingListFacade<PCClass> _classes;
  final DelegatingListFacade<Skill> _skills;
  final DelegatingListFacade<Deity> _deities;
  final DelegatingListFacade<PCTemplate> _templates;
  final DelegatingListFacade<PcAlignment> _alignments;
  final DelegatingListFacade<Kit> _kits;
  final DelegatingListFacade<PCStat> _stats;
  final DelegatingListFacade<Campaign> _campaigns;
  final DelegatingListFacade<BodyStructure> _bodyStructures;
  final DelegatingListFacade<EquipmentFacade> _equipment;
  final DelegatingListFacade<String> _xpTableNames;
  final DelegatingListFacade<GearBuySellFacade> _gearBuySellSchemes;
  final DelegatingListFacade<String> _characterTypes;
  final DelegatingListFacade<SizeAdjustment> _sizes;
  final _DelegatingAbilitiesMap _abilities;

  final DataSetFacade _delegate;

  DelegatingDataSet(DataSetFacade delegate)
      : _delegate = delegate,
        _abilities = _DelegatingAbilitiesMap(delegate.getAbilities()),
        _races = DelegatingListFacade(delegate.getRaces()),
        _classes = DelegatingListFacade(delegate.getClasses()),
        _deities = DelegatingListFacade(delegate.getDeities()),
        _skills = DelegatingListFacade(delegate.getSkills()),
        _templates = DelegatingListFacade(delegate.getTemplates()),
        _alignments = DelegatingListFacade(delegate.getAlignments()),
        _kits = DelegatingListFacade(delegate.getKits()),
        _stats = DelegatingListFacade(delegate.getStats()),
        _campaigns = DelegatingListFacade(delegate.getCampaigns()),
        _bodyStructures =
            DelegatingListFacade(delegate.getEquipmentLocations()),
        _equipment = DelegatingListFacade(delegate.getEquipment()),
        _xpTableNames = DelegatingListFacade(delegate.getXpTableNames()),
        _gearBuySellSchemes =
            DelegatingListFacade(delegate.getGearBuySellSchemes()),
        _characterTypes = DelegatingListFacade(delegate.getCharacterTypes()),
        _sizes = DelegatingListFacade(delegate.getSizes());

  /// Sever connections to prevent memory leaks after character close.
  void detachDelegates() {
    _abilities.detach();
    _races.setDelegate(null);
    _classes.setDelegate(null);
    _deities.setDelegate(null);
    _skills.setDelegate(null);
    _templates.setDelegate(null);
    _alignments.setDelegate(null);
    _kits.setDelegate(null);
    _stats.setDelegate(null);
    _campaigns.setDelegate(null);
    _bodyStructures.setDelegate(null);
    _equipment.setDelegate(null);
    _xpTableNames.setDelegate(null);
    _gearBuySellSchemes.setDelegate(null);
    _characterTypes.setDelegate(null);
    _sizes.setDelegate(null);
  }

  @override
  MapFacade<AbilityCategory, ListFacade<AbilityFacade>> getAbilities() =>
      _abilities;

  @override
  List<AbilityFacade> getPrereqAbilities(AbilityFacade abilityFacade) =>
      _delegate.getPrereqAbilities(abilityFacade);

  @override
  ListFacade<Skill> getSkills() => _skills;

  @override
  ListFacade<Race> getRaces() => _races;

  @override
  ListFacade<PCClass> getClasses() => _classes;

  @override
  ListFacade<Deity> getDeities() => _deities;

  @override
  ListFacade<PCTemplate> getTemplates() => _templates;

  @override
  ListFacade<Campaign> getCampaigns() => _campaigns;

  @override
  GameMode getGameMode() => _delegate.getGameMode();

  @override
  ListFacade<PcAlignment> getAlignments() => _alignments;

  @override
  ListFacade<PCStat> getStats() => _stats;

  @override
  Skill? getSpeakLanguageSkill() => _delegate.getSpeakLanguageSkill();

  @override
  ListFacade<EquipmentFacade> getEquipment() => _equipment;

  @override
  void addEquipment(EquipmentFacade equip) => _delegate.addEquipment(equip);

  @override
  ListFacade<BodyStructure> getEquipmentLocations() => _bodyStructures;

  @override
  ListFacade<String> getXpTableNames() => _xpTableNames;

  @override
  ListFacade<String> getCharacterTypes() => _characterTypes;

  @override
  ListFacade<GearBuySellFacade> getGearBuySellSchemes() => _gearBuySellSchemes;

  @override
  ListFacade<Kit> getKits() => _kits;

  @override
  ListFacade<SizeAdjustment> getSizes() => _sizes;

  @override
  void refreshEquipment() => _delegate.refreshEquipment();
}

// ---------------------------------------------------------------------------

class _DelegatingAbilitiesMap
    implements MapFacade<AbilityCategory, ListFacade<AbilityFacade>> {
  final Map<AbilityCategory, DelegatingListFacade<AbilityFacade>>
      _abilitiesMap = {};
  final MapFacade<AbilityCategory, ListFacade<AbilityFacade>>
      _abilitiesDelegate;
  final List<dynamic> _mapListeners = [];

  _DelegatingAbilitiesMap(this._abilitiesDelegate) {
    _populateMap();
    _abilitiesDelegate.addMapListener(_onMapChanged);
  }

  void detach() {
    _abilitiesDelegate.removeMapListener(_onMapChanged);
    for (DelegatingListFacade<AbilityFacade> list in _abilitiesMap.values) {
      list.setDelegate(null);
    }
  }

  void _onMapChanged(dynamic event) {
    // Handle map events: keyAdded, keyRemoved, keyModified, valueChanged, etc.
    switch (event.type) {
      case 'keyAdded':
        AbilityCategory key = event.key as AbilityCategory;
        DelegatingListFacade<AbilityFacade> newValue =
            DelegatingListFacade(event.newValue as ListFacade<AbilityFacade>);
        _abilitiesMap[key] = newValue;
        _fireKeyAdded(key, newValue);
        break;
      case 'keyRemoved':
        AbilityCategory key = event.key as AbilityCategory;
        DelegatingListFacade<AbilityFacade>? oldValue =
            _abilitiesMap.remove(key);
        if (oldValue != null) {
          _fireKeyRemoved(key, oldValue);
          oldValue.setDelegate(null);
        }
        break;
      case 'valueChanged':
        AbilityCategory key = event.key as AbilityCategory;
        DelegatingListFacade<AbilityFacade>? oldValue = _abilitiesMap[key];
        DelegatingListFacade<AbilityFacade> newValue =
            DelegatingListFacade(event.newValue as ListFacade<AbilityFacade>);
        _abilitiesMap[key] = newValue;
        _fireValueChanged(key, oldValue, newValue);
        oldValue?.setDelegate(null);
        break;
      case 'keysChanged':
        List<DelegatingListFacade<AbilityFacade>> deadLists =
            List.of(_abilitiesMap.values);
        _abilitiesMap.clear();
        _populateMap();
        for (DelegatingListFacade<AbilityFacade> list in deadLists) {
          list.setDelegate(null);
        }
        break;
    }
  }

  void _populateMap() {
    for (AbilityCategory key in _abilitiesDelegate.getKeys()) {
      ListFacade<AbilityFacade>? value = _abilitiesDelegate.getValue(key);
      if (value != null) {
        _abilitiesMap[key] = DelegatingListFacade(value);
      }
    }
  }

  @override
  Set<AbilityCategory> getKeys() => _abilitiesDelegate.getKeys();

  @override
  ListFacade<AbilityFacade>? getValue(AbilityCategory key) =>
      _abilitiesMap[key];

  @override
  void addMapListener(dynamic listener) => _mapListeners.add(listener);

  @override
  void removeMapListener(dynamic listener) => _mapListeners.remove(listener);

  void _fireKeyAdded(AbilityCategory key, dynamic value) {}
  void _fireKeyRemoved(AbilityCategory key, dynamic value) {}
  void _fireValueChanged(
      AbilityCategory key, dynamic oldValue, dynamic newValue) {}
}
