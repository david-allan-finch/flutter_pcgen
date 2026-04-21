// Translation of pcgen.gui2.tools.TipOfTheDayHandler

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The comment character used in PCGen LST files.
const int _lineCommentChar = 0x23; // '#'

/// Singleton that manages the list of "Tip of the Day" strings.
///
/// Tips are loaded from a plain-text file (one tip per non-blank,
/// non-comment line).  The handler persists the index of the last-shown
/// tip across sessions via [SharedPreferences].
///
/// Depends on the `shared_preferences` package.  Add to pubspec.yaml:
///
///   dependencies:
///     shared_preferences: ^2.0.0
final class TipOfTheDayHandler {
  // Preference keys
  static const String _prefKeyLastTip = 'TipOfTheDay.lastTip';
  static const String _prefKeyShowTip = 'TipOfTheDay.showTipOfTheDay';

  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------

  static TipOfTheDayHandler? _instance;

  /// Returns the singleton instance, creating it on first access.
  static TipOfTheDayHandler getInstance() {
    _instance ??= TipOfTheDayHandler._();
    return _instance!;
  }

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<String>? _tipList;
  int _lastNumber = -1;
  SharedPreferences? _prefs;

  TipOfTheDayHandler._();

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Must be called once before using the handler (loads persisted state).
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _lastNumber = _prefs!.getInt(_prefKeyLastTip) ?? -1;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// The index of the last tip that was shown.
  int get lastNumber => _lastNumber;

  /// Load tips from a file at [tipsFilePath].
  ///
  /// The file is a plain-text file: blank lines and lines whose first
  /// non-whitespace character is `#` are ignored.
  Future<void> loadTips(String tipsFilePath) async {
    _tipList = [];
    final file = File(tipsFilePath);
    if (!file.existsSync()) {
      debugPrint('TipOfTheDayHandler: tips file not found at $tipsFilePath');
      return;
    }
    try {
      final contents = await file.readAsString();
      _parseTips(contents);
      debugPrint('TipOfTheDayHandler: loaded ${_tipList!.length} tips from $tipsFilePath');
    } catch (e) {
      debugPrint('TipOfTheDayHandler: unable to load tips file $tipsFilePath: $e');
    }
  }

  /// Load tips from a [String] (e.g. from a Flutter asset).
  void loadTipsFromString(String contents) {
    _tipList = [];
    _parseTips(contents);
    debugPrint('TipOfTheDayHandler: loaded ${_tipList!.length} tips from string');
  }

  /// Whether any tips are loaded.
  bool hasTips() => (_tipList != null) && _tipList!.isNotEmpty;

  /// Advance to the next tip and return it, wrapping around at the end.
  /// Returns an empty string if no tips are loaded.
  Future<String> getNextTip() async {
    if (!hasTips()) return '';
    _lastNumber++;
    if (_lastNumber >= _tipList!.length) _lastNumber = 0;
    await _saveLastNumber();
    return _tipList![_lastNumber];
  }

  /// Move to the previous tip and return it, wrapping around at the start.
  /// Returns an empty string if no tips are loaded.
  Future<String> getPrevTip() async {
    if (!hasTips()) return '';
    _lastNumber--;
    if (_lastNumber < 0) _lastNumber = _tipList!.length - 1;
    await _saveLastNumber();
    return _tipList![_lastNumber];
  }

  /// Whether the "Tip of the Day" dialog should be shown on startup.
  static Future<bool> shouldShowTipOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyShowTip) ?? true;
  }

  /// Persist the preference for showing the tip dialog.
  static Future<void> setShowTipOfTheDay(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyShowTip, value);
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  void _parseTips(String contents) {
    final lines = contents.split(RegExp(r'\r?\n'));
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.codeUnitAt(0) == _lineCommentChar) continue;
      _tipList!.add(line);
    }
  }

  Future<void> _saveLastNumber() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_prefKeyLastTip, _lastNumber);
  }
}
