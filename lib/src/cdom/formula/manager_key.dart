// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.ManagerKey

/// Typed keys for storing objects in a formula Manager.
class TypedKey<T> {
  const TypedKey();
}

class ManagerKey {
  ManagerKey._();

  /// Key for storing a LoadContext in a Manager.
  static const TypedKey<dynamic> context = TypedKey<dynamic>();

  /// Key for storing a ReferenceDependency in a Manager.
  static const TypedKey<dynamic> references = TypedKey<dynamic>();
}
