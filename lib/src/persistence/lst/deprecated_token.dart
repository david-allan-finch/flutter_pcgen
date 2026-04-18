// Copyright 2016 Andrew Maitland <amaitland@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.DeprecatedToken

/// Interface for LST tokens that have been deprecated. Provides a human-readable
/// message explaining the deprecation and how to update the data.
abstract interface class DeprecatedToken {
  /// Returns a message describing why [value] for the token is deprecated
  /// and how the user can fix it, given [obj] being built.
  String getMessage(dynamic obj, String value);
}
