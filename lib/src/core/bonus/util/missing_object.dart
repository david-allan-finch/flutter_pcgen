// Placeholder used when a Bonus class cannot locate the referenced object.
class MissingObject {
  final String _objectName;

  MissingObject(String aName) : _objectName = aName;

  String getObjectName() => _objectName;
}
