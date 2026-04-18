/// A GroupingState indicates how a PrimitiveChoiceSet or PrimitiveChoiceFilter
/// can be combined.
enum GroupingState {
  /// INVALID indicates that the PrimitiveChoiceSet has been constructed in a
  /// way that means the result is non-sensical.
  invalid,

  /// ALLOWS_NONE indicates that the underlying Set cannot be logically
  /// combined with any other set.
  allowsNone,

  /// ALLOWS_INTERSECTION indicates that the underlying set can be combined in
  /// a logical AND (intersection), but not in a logical OR (union).
  allowsIntersection,

  /// ALLOWS_UNION indicates that the underlying set can be combined in a
  /// logical OR (union), but not in a logical AND (intersection).
  allowsUnion,

  /// ANY indicates that any form of grouping (union or intersection) can be
  /// used with the set.
  any,

  /// EMPTY is a starting state of not having any GroupingState.
  empty;

  GroupingState add(GroupingState state) {
    switch (this) {
      case invalid:
        return invalid;
      case allowsNone:
        if (state != empty) {
          return invalid;
        }
        return allowsNone;
      case allowsIntersection:
        if (state == allowsIntersection || state == empty || state == any) {
          return allowsIntersection;
        }
        return invalid;
      case allowsUnion:
        if (state == allowsUnion || state == empty || state == any) {
          return allowsUnion;
        }
        return invalid;
      case any:
        if (state == allowsNone) {
          return invalid;
        }
        return state == empty ? any : state;
      case empty:
        return state;
    }
  }

  GroupingState negate() {
    switch (this) {
      case invalid:
        return invalid;
      case allowsNone:
        return invalid;
      case allowsIntersection:
        return any;
      case allowsUnion:
        return any;
      case any:
        return any;
      case empty:
        return allowsNone;
    }
  }

  GroupingState reduce() {
    switch (this) {
      case invalid:
        return invalid;
      case allowsNone:
        return any;
      case allowsIntersection:
        return any;
      case allowsUnion:
        return allowsUnion;
      case any:
        return any;
      case empty:
        return empty;
    }
  }

  GroupingState compound(GroupingState state) {
    switch (this) {
      case invalid:
        return invalid;
      case allowsNone:
        return allowsNone;
      case allowsIntersection:
        return state == allowsUnion ? invalid : any;
      case allowsUnion:
        return state == allowsIntersection ? invalid : any;
      case any:
        return any;
      case empty:
        return empty;
    }
  }

  bool isValid() {
    switch (this) {
      case invalid:
        return false;
      case allowsNone:
        return true;
      case allowsIntersection:
        return true;
      case allowsUnion:
        return true;
      case any:
        return true;
      case empty:
        return false;
    }
  }
}
