class TypedKey<T> {
  final T? defaultValue;
  const TypedKey({this.defaultValue});

  T? cast(Object? value) => value as T?;
}
