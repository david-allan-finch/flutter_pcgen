//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui3.preferences.EquipmentPreferencesPanelController

import 'package:flutter/material.dart';
import 'equipment_preferences_model.dart';

/// Controller/widget for the Equipment preferences panel.
class EquipmentPreferencesPanelController extends StatelessWidget {
  final EquipmentPreferencesModel model;

  const EquipmentPreferencesPanelController({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (ctx, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Auto Resize Equipment'),
            value: model.autoResize,
            onChanged: model.setAutoResize,
          ),
          SwitchListTile(
            title: const Text('Masterwork Items have Max Dex Penalty'),
            value: model.masterworkMaxDex,
            onChanged: model.setMasterworkMaxDex,
          ),
          SwitchListTile(
            title: const Text('Ignore Cost for Auto-Equip'),
            value: model.ignoreCostForAutoEquip,
            onChanged: model.setIgnoreCostForAutoEquip,
          ),
          SwitchListTile(
            title: const Text('Allow Proficiency with Armor as Shield'),
            value: model.allowProfWithArmorAsShield,
            onChanged: model.setAllowProfWithArmorAsShield,
          ),
          SwitchListTile(
            title: const Text('Simple Equipment Mastery'),
            value: model.simpleEquipmentMastery,
            onChanged: model.setSimpleEquipmentMastery,
          ),
          ListTile(
            title: const Text('Maximum Potion Level'),
            trailing: SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: model.potionMaxLevel,
                keyboardType: TextInputType.number,
                onChanged: model.setPotionMaxLevel,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Maximum Wand Level'),
            trailing: SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: model.wandMaxLevel,
                keyboardType: TextInputType.number,
                onChanged: model.setWandMaxLevel,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
