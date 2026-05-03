//
// Copyright 2005 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.CDOMObjectKey
import 'package:flutter_pcgen/src/base/util/case_insensitive_map.dart';

// Typesafe key for typed Object storage in CDOMObject.
class CDOMObjectKey<T> {
  static final CaseInsensitiveMap<CDOMObjectKey<dynamic>> _typeMap = CaseInsensitiveMap();
  static int _ordinalCount = 0;

  // Commonly used named constants (mirrors Java's static final fields).
  static final CDOMObjectKey<bool> useSpellSpellStat =
      getConstant<bool>('USE_SPELL_SPELL_STAT', defaultValue: false);
  static final CDOMObjectKey<bool> casterWithoutSpellStat =
      getConstant<bool>('CASTER_WITHOUT_SPELL_STAT', defaultValue: false);
  static final CDOMObjectKey<dynamic> spellStat =
      getConstant<dynamic>('SPELL_STAT');
  static final CDOMObjectKey<bool> hasBonusSpellStat =
      getConstant<bool>('HAS_BONUS_SPELL_STAT');
  static final CDOMObjectKey<dynamic> bonusSpellStat =
      getConstant<dynamic>('BONUS_SPELL_STAT');
  static final CDOMObjectKey<dynamic> classSpelllist =
      getConstant<dynamic>('CLASS_SPELLLIST');
  static final CDOMObjectKey<dynamic> domainSpelllist =
      getConstant<dynamic>('DOMAIN_SPELLLIST');
  static final CDOMObjectKey<dynamic> visibility =
      getConstant<dynamic>('VISIBILITY');
  static final CDOMObjectKey<bool> removable =
      getConstant<bool>('REMOVABLE');
  static final CDOMObjectKey<dynamic> sourceCampaign =
      getConstant<dynamic>('SOURCE_CAMPAIGN');
  static final CDOMObjectKey<dynamic> sourceDate =
      getConstant<dynamic>('SOURCE_DATE');
  static final CDOMObjectKey<dynamic> tokenParent =
      getConstant<dynamic>('TOKEN_PARENT');
  static final CDOMObjectKey<dynamic> baseItem =
      getConstant<dynamic>('BASE_ITEM');
  static final CDOMObjectKey<dynamic> choice =
      getConstant<dynamic>('CHOICE');
  static final CDOMObjectKey<dynamic> chooseInfo =
      getConstant<dynamic>('CHOOSE_INFO');
  static final CDOMObjectKey<bool> multipleAllowed =
      getConstant<bool>('MULTIPLE_ALLOWED', defaultValue: false);
  static final CDOMObjectKey<bool> stacks =
      getConstant<bool>('STACKS', defaultValue: false);
  static final CDOMObjectKey<dynamic> assignToAll =
      getConstant<dynamic>('ASSIGN_TO_ALL');
  static final CDOMObjectKey<bool> namePI =
      getConstant<bool>('NAME_PI', defaultValue: false);
  static final CDOMObjectKey<dynamic> parent =
      getConstant<dynamic>('PARENT');
  static final CDOMObjectKey<dynamic> exchangeLevel =
      getConstant<dynamic>('EXCHANGE_LEVEL');
  static final CDOMObjectKey<dynamic> modControl =
      getConstant<dynamic>('MOD_CONTROL');
  static final CDOMObjectKey<dynamic> modifyChoice =
      getConstant<dynamic>('MODIFY_CHOICE');
  static final CDOMObjectKey<bool> isDefaultSize =
      getConstant<bool>('IS_DEFAULT_SIZE', defaultValue: false);
  static final CDOMObjectKey<dynamic> subclassCategory =
      getConstant<dynamic>('SUBCLASS_CATEGORY');
  static final CDOMObjectKey<dynamic> domainSpellList =
      getConstant<dynamic>('DOMAIN_SPELLLIST');

  final String _fieldName;
  final T? _defaultValue;
  final int ordinal;
  final T Function(dynamic)? _caster;

  CDOMObjectKey._(this._fieldName, this._defaultValue, this._caster)
      : ordinal = _ordinalCount++;

  T? getDefault() => _defaultValue;

  T? cast(dynamic value) {
    if (value == null) return null;
    if (_caster != null) return _caster!(value);
    return value as T?;
  }

  @override
  String toString() => _fieldName;

  static CDOMObjectKey<T> getConstant<T>(String name,
      {T? defaultValue, T Function(dynamic)? caster}) {
    final existing = _typeMap[name];
    if (existing != null) return existing as CDOMObjectKey<T>;
    final key = CDOMObjectKey<T>._(name, defaultValue, caster);
    _typeMap[name] = key;
    return key;
  }

  static CDOMObjectKey<T> valueOf<T>(String name) {
    final key = _typeMap[name];
    if (key == null) throw ArgumentError('$name is not a previously defined CDOMObjectKey');
    return key as CDOMObjectKey<T>;
  }

  static Iterable<CDOMObjectKey<dynamic>> getAllConstants() =>
      List.unmodifiable(_typeMap.values);

  static void clearConstants() => _typeMap.clear();
}
