// A movement type and rate pair from the MOVE: token (e.g. Walk 30, Fly 60).
class SimpleMovement {
  final String movementType; // e.g. 'Walk', 'Fly', 'Swim'
  final int movement; // movement rate in feet

  SimpleMovement(this.movementType, this.movement) {
    if (movement < 0) throw ArgumentError('Movement must be >= 0: $movement');
  }

  @override
  String toString() => '$movementType $movement';
}
