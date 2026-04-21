//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.rules.persistence.token.QualifierToken
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
