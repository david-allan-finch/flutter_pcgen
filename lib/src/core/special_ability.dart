import 'text_property.dart';

/// Represents a Special Ability in PCGen.
///
/// A special ability has a name and an optional property description (propDesc)
/// that is appended to the display text in parentheses.
final class SpecialAbility extends TextProperty implements Comparable<Object> {
  String _propDesc = '';

  /// Default constructor.
  SpecialAbility();

  /// Constructor with name.
  SpecialAbility.withName(String name) : super.withName(name);

  /// Constructor with name and property description.
  SpecialAbility.withNameAndDesc(String name, String propDesc)
      : _propDesc = propDesc,
        super.withName(name);

  /// Set the description of the Special Ability.
  void setSADesc(String saDesc) => setPropDesc(saDesc);

  /// Get the description of the Special Ability.
  String getSADesc() => getPropDesc();

  @override
  int compareTo(Object obj) {
    return getKeyName().toLowerCase().compareTo(obj.toString().toLowerCase());
  }

  @override
  String toString() => getDisplayName();

  /// Set the property description.
  void setPropDesc(String propDesc) {
    _propDesc = propDesc;
  }

  String getPropDesc() => _propDesc;

  @override
  String getText() {
    final base = super.getText();
    if (_propDesc.isEmpty) {
      return base;
    }
    return '$base ($_propDesc)';
  }
}
