// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.core.system.MigrationRule

/// Describes how to migrate an object key from one version to another.
class MigrationRule {
  final ObjectType objectType;
  String? oldKey;
  String? newKey;
  String? oldCategory;
  String? newCategory;
  String? maxVer;
  String? maxDevVer;
  String? minVer;
  String? minDevVer;

  /// Creates a migration rule for a categorized object (e.g. ABILITY).
  MigrationRule.categorized(this.objectType, this.oldCategory, this.oldKey)
      : assert(objectType.isCategorized);

  /// Creates a migration rule for a non-categorized object (e.g. RACE).
  MigrationRule.uncategorized(this.objectType, this.oldKey)
      : assert(!objectType.isCategorized);
}

/// The type of object this migration rule applies to.
enum ObjectType {
  ability(categorized: true),
  equipment(categorized: false),
  race(categorized: false),
  source(categorized: false),
  spell(categorized: false);

  final bool isCategorized;
  const ObjectType({required this.isCategorized});
}
