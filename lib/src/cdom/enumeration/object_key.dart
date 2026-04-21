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
// Translation of pcgen.cdom.enumeration.ObjectKey
import 'package:flutter_pcgen/src/base/util/case_insensitive_map.dart';

// Typesafe key for typed Object storage in CDOMObject.
class ObjectKey<T> {
  static final CaseInsensitiveMap<ObjectKey<dynamic>> _typeMap = CaseInsensitiveMap();
  static int _ordinalCount = 0;

  // Commonly used named constants (mirrors Java's static final fields).
  static final ObjectKey<bool> useSpellSpellStat =
      getConstant<bool>('USE_SPELL_SPELL_STAT', defaultValue: false);
  static final ObjectKey<bool> casterWithoutSpellStat =
      getConstant<bool>('CASTER_WITHOUT_SPELL_STAT', defaultValue: false);
  static final ObjectKey<dynamic> spellStat =
      getConstant<dynamic>('SPELL_STAT');
  static final ObjectKey<bool> hasBonusSpellStat =
      getConstant<bool>('HAS_BONUS_SPELL_STAT');
  static final ObjectKey<dynamic> bonusSpellStat =
      getConstant<dynamic>('BONUS_SPELL_STAT');
  static final ObjectKey<dynamic> classSpelllist =
      getConstant<dynamic>('CLASS_SPELLLIST');
  static final ObjectKey<dynamic> domainSpelllist =
      getConstant<dynamic>('DOMAIN_SPELLLIST');
  static final ObjectKey<dynamic> visibility =
      getConstant<dynamic>('VISIBILITY');
  static final ObjectKey<bool> removable =
      getConstant<bool>('REMOVABLE');
  static final ObjectKey<dynamic> sourceCampaign =
      getConstant<dynamic>('SOURCE_CAMPAIGN');
  static final ObjectKey<dynamic> sourceDate =
      getConstant<dynamic>('SOURCE_DATE');
  static final ObjectKey<dynamic> tokenParent =
      getConstant<dynamic>('TOKEN_PARENT');
  static final ObjectKey<dynamic> baseItem =
      getConstant<dynamic>('BASE_ITEM');
  static final ObjectKey<dynamic> choice =
      getConstant<dynamic>('CHOICE');
  static final ObjectKey<dynamic> chooseInfo =
      getConstant<dynamic>('CHOOSE_INFO');
  static final ObjectKey<bool> multipleAllowed =
      getConstant<bool>('MULTIPLE_ALLOWED', defaultValue: false);
  static final ObjectKey<bool> stacks =
      getConstant<bool>('STACKS', defaultValue: false);
  static final ObjectKey<dynamic> assignToAll =
      getConstant<dynamic>('ASSIGN_TO_ALL');
  static final ObjectKey<bool> namePI =
      getConstant<bool>('NAME_PI', defaultValue: false);
  static final ObjectKey<dynamic> parent =
      getConstant<dynamic>('PARENT');
  static final ObjectKey<dynamic> exchangeLevel =
      getConstant<dynamic>('EXCHANGE_LEVEL');
  static final ObjectKey<dynamic> modControl =
      getConstant<dynamic>('MOD_CONTROL');
  static final ObjectKey<dynamic> modifyChoice =
      getConstant<dynamic>('MODIFY_CHOICE');
  static final ObjectKey<bool> isDefaultSize =
      getConstant<bool>('IS_DEFAULT_SIZE', defaultValue: false);
  static final ObjectKey<dynamic> subclassCategory =
      getConstant<dynamic>('SUBCLASS_CATEGORY');
  static final ObjectKey<dynamic> domainSpellList =
      getConstant<dynamic>('DOMAIN_SPELLLIST');

  final String _fieldName;
  final T? _defaultValue;
  final int ordinal;
  final T Function(dynamic)? _caster;

  ObjectKey._(this._fieldName, this._defaultValue, this._caster)
      : ordinal = _ordinalCount++;

  T? getDefault() => _defaultValue;

  T? cast(dynamic value) {
    if (value == null) return null;
    if (_caster != null) return _caster!(value);
    return value as T?;
  }

  @override
  String toString() => _fieldName;

  static ObjectKey<T> getConstant<T>(String name,
      {T? defaultValue, T Function(dynamic)? caster}) {
    final existing = _typeMap[name];
    if (existing != null) return existing as ObjectKey<T>;
    final key = ObjectKey<T>._(name, defaultValue, caster);
    _typeMap[name] = key;
    return key;
  }

  static ObjectKey<T> valueOf<T>(String name) {
    final key = _typeMap[name];
    if (key == null) throw ArgumentError('$name is not a previously defined ObjectKey');
    return key as ObjectKey<T>;
  }

  static Iterable<ObjectKey<dynamic>> getAllConstants() =>
      List.unmodifiable(_typeMap.values());

  static void clearConstants() => _typeMap.clear();
}
