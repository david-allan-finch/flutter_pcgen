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
