// Translation of pcgen.system.LegacySettings

import 'property_context.dart';

/// Holds legacy/deprecated PCGen settings.
final class LegacySettings extends PropertyContext {
  static final LegacySettings _instance = LegacySettings._();

  LegacySettings._() : super('pcgen.legacy');

  static LegacySettings getInstance() => _instance;
}
