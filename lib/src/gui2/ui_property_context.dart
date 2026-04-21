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
// Translation of pcgen.gui2.UIPropertyContext

import 'dart:ui' show Color;
import '../facade/core/character_facade.dart';

/// Holds UI-related user preferences such as screen position and colours.
class UIPropertyContext {
  static const String customItemColor = 'customItemColor';
  static const String notQualifiedColor = 'notQualifiedColor';
  static const String automaticColor = 'automaticColor';
  static const String virtualColor = 'virtualColor';
  static const String qualifiedColor = 'qualifiedColor';
  static const String sourceStatusReleaseColor = 'sourceStatusReleaseColor';
  static const String sourceStatusAlphaColor = 'sourceStatusAlphaColor';
  static const String sourceStatusBetaColor = 'sourceStatusBetaColor';
  static const String sourceStatusTestColor = 'sourceStatusTestColor';
  static const String alwaysOpenExportFile = 'alwaysOpenExportFile';
  static const String defaultOsType = 'defaultOSType';
  static const String defaultPdfOutputSheet = 'defaultPdfOutputSheet';
  static const String defaultHtmlOutputSheet = 'defaultHtmlOutputSheet';
  static const String saveOutputSheetWithPc = 'saveOutputSheetWithPC';
  static const String cleanupTempFiles = 'cleanupTempFiles';
  static const String skipSourceSelection = 'SourceSelectionDialog.skipOnStart';
  static const String sourceUseBasicKey = 'SourceSelectionDialog.useBasic';
  static const String cPropInitialTab = 'initialTab';

  static const int chooserSingleChoiceMethodNone = 0;

  static UIPropertyContext? _instance;
  final Map<String, String> _properties = {};
  final UIPropertyContext? _parent;

  UIPropertyContext._({UIPropertyContext? parent}) : _parent = parent {
    if (parent == null) {
      _setColor(customItemColor, const Color(0xFF0000FF)); // Blue
      _setColor(notQualifiedColor, const Color(0xFFFF0000)); // Red
      _setColor(automaticColor, const Color(0xFFB2B200));
      _setColor(virtualColor, const Color(0xFFFF00FF)); // Magenta
      _setColor(qualifiedColor, const Color(0xFF000000)); // Black
    }
  }

  static UIPropertyContext getInstance() {
    _instance ??= UIPropertyContext._();
    return _instance!;
  }

  static UIPropertyContext createContext(String name) {
    return getInstance()._createChildContext(name);
  }

  UIPropertyContext _createChildContext(String childName) {
    return UIPropertyContext._(parent: this);
  }

  String? getProperty(String key) {
    if (_properties.containsKey(key)) return _properties[key];
    return _parent?.getProperty(key);
  }

  void setProperty(String key, String value) {
    _properties[key] = value;
  }

  String initProperty(String key, String defaultValue) {
    if (!_properties.containsKey(key)) _properties[key] = defaultValue;
    return _properties[key]!;
  }

  bool getBoolean(String key, {bool defaultValue = false}) {
    final v = getProperty(key);
    if (v == null) return defaultValue;
    return v == 'true';
  }

  void setBoolean(String key, bool value) {
    setProperty(key, value.toString());
  }

  bool initBoolean(String key, bool defaultValue) {
    final prop = initProperty(key, defaultValue.toString());
    return prop == 'true';
  }

  int getInt(String key, {int defaultValue = 0}) {
    final v = getProperty(key);
    if (v == null) return defaultValue;
    return int.tryParse(v) ?? defaultValue;
  }

  void setInt(String key, int value) {
    setProperty(key, value.toString());
  }

  int initInt(String key, int defaultValue) {
    final prop = initProperty(key, defaultValue.toString());
    return int.tryParse(prop) ?? defaultValue;
  }

  Color? _getColor(String key) {
    final prop = getProperty(key);
    if (prop == null) return null;
    return _parseColor(prop);
  }

  void _setColor(String key, Color color) {
    setProperty(key, _colorToRgbString(color));
  }

  Color _initColor(String key, Color defaultValue) {
    final prop = initProperty(key, _colorToRgbString(defaultValue));
    return _parseColor(prop) ?? defaultValue;
  }

  static Color? _parseColor(String value) {
    try {
      final hex = value.replaceFirst('#', '').replaceFirst('0x', '');
      final padded = hex.length == 6 ? 'FF$hex' : hex;
      return Color(int.parse(padded, radix: 16));
    } catch (_) {
      return null;
    }
  }

  static String _colorToRgbString(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static Color? getCustomItemColor() => getInstance()._getColor(customItemColor);

  static void setQualifiedColor(Color color) =>
      getInstance()._setColor(qualifiedColor, color);
  static Color? getQualifiedColorStatic() =>
      getInstance()._getColor(qualifiedColor);

  static void setNotQualifiedColor(Color color) =>
      getInstance()._setColor(notQualifiedColor, color);
  static Color? getNotQualifiedColor() =>
      getInstance()._getColor(notQualifiedColor);

  static void setAutomaticColor(Color color) =>
      getInstance()._setColor(automaticColor, color);
  static Color? getAutomaticColor() => getInstance()._getColor(automaticColor);

  static void setVirtualColor(Color color) =>
      getInstance()._setColor(virtualColor, color);
  static Color? getVirtualColor() => getInstance()._getColor(virtualColor);

  static void setSourceStatusReleaseColor(Color color) =>
      getInstance()._setColor(sourceStatusReleaseColor, color);
  static Color getSourceStatusReleaseColor() =>
      getInstance()._initColor(sourceStatusReleaseColor, const Color(0xFF000000));

  static void setSourceStatusAlphaColor(Color color) =>
      getInstance()._setColor(sourceStatusAlphaColor, color);
  static Color getSourceStatusAlphaColor() =>
      getInstance()._initColor(sourceStatusAlphaColor, const Color(0xFFFF0000));

  static void setSourceStatusBetaColor(Color color) =>
      getInstance()._setColor(sourceStatusBetaColor, color);
  static Color getSourceStatusBetaColor() =>
      getInstance()._initColor(sourceStatusBetaColor, const Color(0xFF800000));

  static void setSourceStatusTestColor(Color color) =>
      getInstance()._setColor(sourceStatusTestColor, color);
  static Color getSourceStatusTestColor() =>
      getInstance()._initColor(sourceStatusTestColor, const Color(0xFFFF00FF));

  static int getSingleChoiceAction() =>
      getInstance().initInt('singleChoiceAction', chooserSingleChoiceMethodNone);

  static void setSingleChoiceAction(int action) =>
      getInstance().setInt('singleChoiceAction', action);

  static String? createCharacterPropertyKey(CharacterFacade character, String key) {
    final file = character.getFileRef().get();
    if (file == null) return null;
    return createFilePropertyKey(file, key);
  }

  static String createFilePropertyKey(String file, String key) {
    return '$file.$key';
  }
}
