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
