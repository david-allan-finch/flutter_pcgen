// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

// Translation of pcgen.cdom.facet.FacetInitialization
// Manages wiring of facet listener relationships at startup.
//
// All facet types referenced here are dynamic (not yet translated) except those
// already in the Dart codebase.

/// FacetInitialization is a utility class that wires facet listener
/// relationships during application initialization.
///
/// This is a singleton-style initializer: call [initialize] once at startup.
final class FacetInitialization {
  static bool _isInitialized = false;

  // Do not instantiate
  FacetInitialization._();

  static void initialize() {
    if (!_isInitialized) {
      _doInitialization();
      _isInitialized = true;
    }
  }

  static void _doInitialization() {
    _doOtherInitialization();
    _doBridges();

    // All facet types below are dynamic (not yet translated).
    // FacetLibrary.getFacet is stubbed as dynamic.
    final dynamic scopedDistributionFacet =
        FacetLibrary.getFacet('ScopedDistributionFacet');
    final dynamic grantedVarFacet = FacetLibrary.getFacet('GrantedVarFacet');
    final dynamic templateFacet = FacetLibrary.getFacet('TemplateFacet');
    final dynamic conditionalTemplateFacet =
        FacetLibrary.getFacet('ConditionalTemplateFacet');
    final dynamic raceFacet = FacetLibrary.getFacet('RaceFacet');
    final dynamic classFacet = FacetLibrary.getFacet('ClassFacet');
    final dynamic classLevelFacet = FacetLibrary.getFacet('ClassLevelFacet');
    final dynamic expandedCampaignFacet =
        FacetLibrary.getFacet('ExpandedCampaignFacet');
    final dynamic equipmentFacet = FacetLibrary.getFacet('EquipmentFacet');
    final dynamic equippedFacet =
        FacetLibrary.getFacet('EquippedEquipmentFacet');
    final dynamic naturalEquipmentFacet =
        FacetLibrary.getFacet('NaturalEquipmentFacet');
    final dynamic activeEquipmentFacet =
        FacetLibrary.getFacet('SourcedEquipmentFacet');
    final dynamic activeEqHeadFacet =
        FacetLibrary.getFacet('ActiveEqHeadFacet');
    final dynamic activeEqModFacet = FacetLibrary.getFacet('ActiveEqModFacet');

    final dynamic globalModifierFacet =
        FacetLibrary.getFacet('GlobalModifierFacet');
    final dynamic bioSetFacet = FacetLibrary.getFacet('BioSetFacet');
    final dynamic bioSetTrackingFacet =
        FacetLibrary.getFacet('BioSetTrackingFacet');
    final dynamic checkFacet = FacetLibrary.getFacet('CheckFacet');

    final dynamic dynamicWatchingFacet =
        FacetLibrary.getFacet('DynamicWatchingFacet');
    final dynamic dynamicFacet = FacetLibrary.getFacet('DynamicFacet');
    final dynamic dynamicConsolidationFacet =
        FacetLibrary.getFacet('DynamicConsolidationFacet');
    final dynamic varScopedFacet = FacetLibrary.getFacet('VarScopedFacet');

    final dynamic autoLangFacet = FacetLibrary.getFacet('AutoLanguageFacet');
    final dynamic weaponProfFacet = FacetLibrary.getFacet('WeaponProfFacet');

    final dynamic levelFacet = FacetLibrary.getFacet('LevelFacet');
    final dynamic sizeFacet = FacetLibrary.getFacet('SizeFacet');
    final dynamic bonusChangeFacet = FacetLibrary.getFacet('BonusChangeFacet');
    final dynamic domainFacet = FacetLibrary.getFacet('DomainFacet');
    final dynamic companionModFacet =
        FacetLibrary.getFacet('CompanionModFacet');
    final dynamic statFacet = FacetLibrary.getFacet('StatFacet');
    final dynamic skillFacet = FacetLibrary.getFacet('SkillFacet');

    final dynamic nwpFacet =
        FacetLibrary.getFacet('NaturalWeaponProfFacet');
    final dynamic userEquipmentFacet =
        FacetLibrary.getFacet('UserEquipmentFacet');
    final dynamic naturalWeaponFacet =
        FacetLibrary.getFacet('NaturalWeaponFacet');
    final dynamic equipSetFacet = FacetLibrary.getFacet('EquipSetFacet');

    final dynamic cdomObjectFacet =
        FacetLibrary.getFacet('CDOMObjectConsolidationFacet');
    final dynamic cdomSourceFacet =
        FacetLibrary.getFacet('CDOMObjectSourceFacet');
    final dynamic charObjectFacet =
        FacetLibrary.getFacet('CharacterConsolidationFacet');
    final dynamic eqObjectFacet =
        FacetLibrary.getFacet('EquipmentConsolidationFacet');
    final dynamic grantedAbilityFacet =
        FacetLibrary.getFacet('GrantedAbilityFacet');
    final dynamic directAbilityFacet =
        FacetLibrary.getFacet('DirectAbilityFacet');
    final dynamic directAbilityInputFacet =
        FacetLibrary.getFacet('DirectAbilityInputFacet');
    final dynamic cabFacet =
        FacetLibrary.getFacet('ConditionallyGrantedAbilityFacet');
    final dynamic simpleAbilityFacet =
        FacetLibrary.getFacet('SimpleAbilityFacet');
    final dynamic abilitySelectionApplication =
        FacetLibrary.getFacet('AbilitySelectionApplication');

    equipmentFacet.addDataFacetChangeListener(naturalEquipmentFacet);
    equippedFacet.addDataFacetChangeListener(activeEquipmentFacet);
    naturalEquipmentFacet.addDataFacetChangeListener(activeEquipmentFacet);
    activeEquipmentFacet.addDataFacetChangeListener(activeEqHeadFacet);
    activeEqHeadFacet.addDataFacetChangeListener(activeEqModFacet);

    nwpFacet.addDataFacetChangeListener(weaponProfFacet);

    dynamicWatchingFacet.addDataFacetChangeListener(dynamicFacet);
    dynamicFacet.addScopeFacetChangeListener(dynamicConsolidationFacet);

    charObjectFacet.addDataFacetChangeListener(naturalWeaponFacet);
    naturalWeaponFacet.addDataFacetChangeListener(equipmentFacet);
    naturalWeaponFacet.addDataFacetChangeListener(userEquipmentFacet);
    naturalWeaponFacet.addDataFacetChangeListener(equipSetFacet);

    classFacet.addLevelChangeListener(levelFacet);
    levelFacet.addLevelChangeListener(conditionalTemplateFacet);
    levelFacet.addLevelChangeListener(sizeFacet);

    grantedAbilityFacet.addDataFacetChangeListener(abilitySelectionApplication);
    grantedAbilityFacet.addDataFacetChangeListener(simpleAbilityFacet);
    directAbilityFacet.addDataFacetChangeListener(grantedAbilityFacet);
    directAbilityInputFacet.addDataFacetChangeListener(grantedAbilityFacet);
    cabFacet.addDataFacetChangeListener(grantedAbilityFacet);

    raceFacet.addDataFacetChangeListener(bioSetTrackingFacet);

    bonusChangeFacet.addBonusChangeListener(sizeFacet, 'SIZEMOD', 'NUMBER');

    grantedVarFacet
        .addDataFacetChangeListener(scopedDistributionFacet); // model done

    expandedCampaignFacet
        .addDataFacetChangeListener(charObjectFacet); // model done
    globalModifierFacet
        .addDataFacetChangeListener(charObjectFacet); // model done
    bioSetFacet.addDataFacetChangeListener(charObjectFacet); // model done
    checkFacet.addDataFacetChangeListener(charObjectFacet); // model done
    classFacet.addDataFacetChangeListener(charObjectFacet); // model done
    domainFacet.addDataFacetChangeListener(charObjectFacet); // model done
    raceFacet.addDataFacetChangeListener(charObjectFacet); // model done
    sizeFacet.addDataFacetChangeListener(charObjectFacet);
    skillFacet.addDataFacetChangeListener(charObjectFacet); // model done
    statFacet.addDataFacetChangeListener(charObjectFacet); // model done
    templateFacet.addDataFacetChangeListener(charObjectFacet); // model done

    // weaponProfList is still just a list of Strings
    classLevelFacet.addDataFacetChangeListener(charObjectFacet); // model done
    simpleAbilityFacet
        .addDataFacetChangeListener(charObjectFacet); // model done
    companionModFacet.addDataFacetChangeListener(charObjectFacet); // model done

    activeEquipmentFacet.addDataFacetChangeListener(eqObjectFacet);
    activeEqHeadFacet.addDataFacetChangeListener(eqObjectFacet);
    activeEqModFacet.addDataFacetChangeListener(eqObjectFacet);

    eqObjectFacet.addDataFacetChangeListener(cdomObjectFacet);
    charObjectFacet.addDataFacetChangeListener(cdomObjectFacet);

    cdomObjectFacet.addDataFacetChangeListener(nwpFacet);
    cdomSourceFacet.addDataFacetChangeListener(autoLangFacet);
    cdomSourceFacet.addDataFacetChangeListener(dynamicWatchingFacet);

    cdomObjectFacet.addDataFacetChangeListener(varScopedFacet);
    dynamicConsolidationFacet
        .addDataFacetChangeListener(varScopedFacet); // model done
  }

  static void _doOtherInitialization() {
    // OutputDB.registerMode("cc", new CodeControlModelFactory());
    // Stub: output registration not yet translated
  }

  static void _doBridges() {
    // Dataset-level facets
    FacetLibrary.getFacet('CDOMWrapperInfoFacet');
    FacetLibrary.getFacet('ObjectWrapperFacet');
    FacetLibrary.getFacet('MasterSkillFacet');
    FacetLibrary.getFacet('MasterAvailableSpellFacet');
    FacetLibrary.getFacet('MasterUsableSkillFacet');
    FacetLibrary.getFacet('EquipmentTypeFacet');
    FacetLibrary.getFacet('ObjectWrapperFacet');
    FacetLibrary.getFacet('CDOMWrapperInfoFacet');
    FacetLibrary.getFacet('HiddenTypeFacet');
    FacetLibrary.getFacet('LoadContextFacet');

    // Bridge facets
    FacetLibrary.getFacet('AgeSetKitFacet');
    FacetLibrary.getFacet('DomainSpellListFacet');
    FacetLibrary.getFacet('NaturalEquipSetFacet');
    FacetLibrary.getFacet('ShieldProfFacet');
    FacetLibrary.getFacet('ArmorProfFacet');
    FacetLibrary.getFacet('MonsterClassFacet');
    FacetLibrary.getFacet('KitChoiceFacet');
    FacetLibrary.getFacet('AddFacet');
    FacetLibrary.getFacet('RemoveFacet');
    FacetLibrary.getFacet('ModifierFacet');
    FacetLibrary.getFacet('RemoteModifierFacet');
    FacetLibrary.getFacet('CalcBonusFacet');
    FacetLibrary.getFacet('DomainSpellsFacet');
    FacetLibrary.getFacet('ObjectAdditionFacet');
    FacetLibrary.getFacet('AddLevelFacet');
    FacetLibrary.getFacet('ChooseDriverFacet');
    FacetLibrary.getFacet('AvailableSpellInputFacet');
    FacetLibrary.getFacet('KnownSpellInputFacet');
    FacetLibrary.getFacet('ClassSkillListFacet');
    FacetLibrary.getFacet('SpellListToAvailableSpellFacet');
    FacetLibrary.getFacet('ChangeProfFacet');
    FacetLibrary.getFacet('ClassLevelChangeFacet');
    FacetLibrary.getFacet('UnconditionalTemplateFacet');

    // OutputDB registrations
    // OutputDB.register("deity", CControl.DEITYINPUT);
    // OutputDB.register("alignment", CControl.ALIGNMENTINPUT);
    // Stub: output registration not yet translated
  }
}

/// Stub for FacetLibrary — returns dynamic facet objects by name.
/// Replace with proper implementation when FacetLibrary is translated.
class FacetLibrary {
  static final Map<String, dynamic> _facets = {};

  static dynamic getFacet(String name) {
    return _facets.putIfAbsent(name, () => _StubFacet(name));
  }
}

/// Stub facet object that accepts any method call without crashing.
class _StubFacet {
  final String _name;
  _StubFacet(this._name);

  @override
  String toString() => '_StubFacet($_name)';

  // noSuchMethod allows calls like addDataFacetChangeListener to silently pass.
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
