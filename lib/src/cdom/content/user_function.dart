import 'user_content.dart';

// A UserFunction is a custom formula function defined in data. It stores the
// original expression string for unparse and provides the parsed function to
// the formula system.
class UserFunction extends UserContent {
  String? _origExpression;
  dynamic _function; // FormulaFunction — typed loosely to avoid deep imports

  @override
  String getDisplayName() => getKeyName();

  void setFunction(String expression) {
    _origExpression = expression;
    // Parsing is deferred to the formula engine when registered.
    // Store expression for later registration.
    _function = expression;
  }

  String? getOriginalExpression() => _origExpression;

  dynamic getFunction() => _function;
}
