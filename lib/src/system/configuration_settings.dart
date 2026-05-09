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
// Translation of pcgen.system.ConfigurationSettings

import 'dart:io';
import 'package:flutter_pcgen/src/system/property_context.dart';

/// Holds directory and other configuration settings for PCGen.
class ConfigurationSettings extends PropertyContext {
  static const String userLanguage = 'userLanguage';
  static const String userCountry = 'userCountry';
  static const String systemsDir = 'systemPath';
  static const String outputSheetsDir = 'osPath';
  static const String previewDir = 'previewPath';
  static const String vendorDataDir = 'vendordataPath';
  static const String homebrewDataDir = 'homebrewdataPath';
  static const String docsDir = 'docsPath';
  static const String pccFilesDir = 'pccFilesPath';
  static const String customDataDir = 'customPath';

  static ConfigurationSettings? _instance;

  /// When set, all '@relative' tokens resolve under this root instead of
  /// looking next to the executable. Used on Android (and other mobile
  /// platforms) where data is downloaded to the app documents directory.
  static String? _dataRoot;

  /// Call this during app startup on platforms where the data files are not
  /// bundled next to the executable (e.g. Android/iOS after download).
  static void setDataRoot(String path) => _dataRoot = path;

  static String? get dataRoot => _dataRoot;

  ConfigurationSettings._(String configFileName) : super(configFileName) {
    setProperty(systemsDir, '@system');
    setProperty(outputSheetsDir, '@outputsheets');
    setProperty(previewDir, '@preview');
    setProperty(docsDir, '@docs');
    setProperty(pccFilesDir, '@data');
  }

  static ConfigurationSettings getInstance() {
    _instance ??= ConfigurationSettings._('pcgen.properties');
    return _instance!;
  }

  static void reset() => _instance = null;

  // ---------------------------------------------------------------------------
  // Resolved path accessors
  // ---------------------------------------------------------------------------

  static String getSystemsDir() =>
      _resolve(getInstance().getProperty(systemsDir) ?? '@system');

  static String getPccFilesDir() =>
      _resolve(getInstance().getProperty(pccFilesDir) ?? '@data');

  static String getOutputSheetsDir() =>
      _resolve(getInstance().getProperty(outputSheetsDir) ?? '@outputsheets');

  static String getPreviewDir() =>
      _resolve(getInstance().getProperty(previewDir) ?? '@preview');

  static String getDocsDir() =>
      _resolve(getInstance().getProperty(docsDir) ?? '@docs');

  static String getCustomDataDir() =>
      _resolve(getInstance().getProperty(customDataDir) ?? '@custom');

  /// Resolves a path token. Tokens starting with '@' are treated as directory
  /// names relative to the data root.
  ///
  /// Resolution order:
  ///   0. Pre-configured [_dataRoot] (Android/iOS — set after data download).
  ///   1. CWD — project directory when running via `flutter run`.
  ///   2. Sibling pcgen repo — dev convenience.
  ///   3. Next to the executable — production desktop build.
  static String _resolve(String path) {
    if (!path.startsWith('@')) return path;
    final relative = path.substring(1);
    final sep = Platform.pathSeparator;

    // 0. Explicit data root (mobile platforms after download).
    if (_dataRoot != null) {
      return '$_dataRoot$sep$relative';
    }

    // 1. CWD — project directory when running via `flutter run`.
    final fromCwd = '${Directory.current.path}$sep$relative';
    if (Directory(fromCwd).existsSync()) return fromCwd;

    // 2. Sibling pcgen repo — dev convenience so data/ doesn't need to be copied.
    final sibling = Directory(
        '${Directory.current.path}$sep..${sep}pcgen$sep$relative');
    if (sibling.existsSync()) return sibling.resolveSymbolicLinksSync();

    // 3. Next to the executable — production (released binary).
    final execDir = File(Platform.resolvedExecutable).parent.path;
    final fromExec = '$execDir$sep$relative';
    if (Directory(fromExec).existsSync()) return fromExec;

    print('PCGen: "$relative" not found in CWD (${Directory.current.path}), '
        'sibling pcgen repo, or next to executable ($execDir)');
    return fromCwd;
  }
}
