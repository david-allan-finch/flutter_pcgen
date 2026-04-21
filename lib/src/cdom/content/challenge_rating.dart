//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.content.ChallengeRating
// Represents a challenge rating value (e.g., 1/4, 1/2, 1, 2, etc).
class ChallengeRating {
  final num _rating;

  const ChallengeRating(this._rating);

  num getRating() => _rating;

  @override
  String toString() {
    if (_rating < 1 && _rating > 0) {
      final denom = (1 / _rating).round();
      return '1/$denom';
    }
    return _rating.toString();
  }

  @override
  bool operator ==(Object other) => other is ChallengeRating && _rating == other._rating;

  @override
  int get hashCode => _rating.hashCode;
}
