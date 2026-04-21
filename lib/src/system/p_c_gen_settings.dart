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
// Translation of pcgen.system.PCGenSettings

import 'property_context.dart';

/// Application-level PCGen settings / options.
final class PCGenSettings extends PropertyContext {
  static final PCGenSettings _instance = PCGenSettings._();

  static PropertyContext optionsContext =
      _instance.createChildContext('pcgen.options');

  static const String optionSaveCustomEquipment = 'saveCustomInLst';
  static const String optionAllowedInSources = 'optionAllowedInSources';
  static const String optionSourcesAllowMultiLine = 'optionSourcesAllowMultiLine';
  static const String optionShowLicense = 'showLicense';
  static const String optionShowMatureOnLoad = 'showMatureOnLoad';
  static const String optionCreatePcgBackup = 'createPcgBackup';
  static const String optionShowWarningAtFirstLevelUp = 'showWarningAtFirstLevelUp';
  static const String optionAutoResizeEquip = 'autoResizeEquip';
  static const String optionAutoloadSourcesAtStart = 'autoloadSourcesAtStart';
  static const String optionAutoloadSourcesWithPc = 'autoloadSourcesWithPC';
  static const String optionAllowOverrideDuplicates = 'allowOverrideDuplicates';

  PCGenSettings._() : super('pcgen.options');

  static PCGenSettings getInstance() => _instance;
}
