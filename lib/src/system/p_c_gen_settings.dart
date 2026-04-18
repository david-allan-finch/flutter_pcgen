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
