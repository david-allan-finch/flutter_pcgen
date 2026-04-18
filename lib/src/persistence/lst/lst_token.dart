// Copyright 2016 Andrew Maitland <amaitland@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.LstToken

/// Interface for LST file tokens that can identify themselves by name.
abstract interface class LstToken {
  String getTokenName();
}
