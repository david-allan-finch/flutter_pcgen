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

import 'property_context.dart';

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
}
