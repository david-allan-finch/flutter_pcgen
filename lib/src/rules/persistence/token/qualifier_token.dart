import '../../../rules/context/load_context.dart';
import 'cdom_token.dart';

/// A QualifierToken selects and filters zero or more objects of a specific
/// type. Typically used as part of a CHOOSE.
abstract interface class QualifierToken<T> implements LstToken {
  /// Initialize the qualifier token.
  /// Returns true if initialization succeeded.
  bool initialize(
    LoadContext context,
    dynamic selectionCreator, // SelectionCreator<T>
    String? condition,
    String? value,
    bool negated,
  );

  /// Returns the reference class (Type) for this qualifier.
  Type getReferenceClass();
}
