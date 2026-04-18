// RollingMethods.dart
// Translated from pcgen/core/RollingMethods.java
// JEP-based dice evaluation (Roll, Top, Reroll inner classes) is stubbed.
// The core roll logic is preserved using dart:math Random.

import 'dart:math' as math;

class RollingMethods {
  RollingMethods._();

  static final math.Random _rng = math.Random();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Roll [times] dice with [sides] faces; keep all.
  static int rollTimesKeepAll(int times, int sides) {
    return _rollKeepTop(times, sides, times, 0);
  }

  /// Roll a single die with [sides] faces.
  static int rollSingle(int sides) {
    return _rng.nextInt(sides) + 1;
  }

  /// Roll [times] dice with [sides] faces, sort them, and return the sum of
  /// those listed in [keep] (0-indexed).
  static int rollKeep(int times, int sides, List<int> keep) {
    final List<int> rolls = List<int>.generate(
        times, (_) => _rng.nextInt(sides))
      ..sort();
    int total = keep.length; // Java code starts accumulator at keep.length
    for (final int k in keep) {
      total += rolls[k];
    }
    return total;
  }

  /// Roll [method] – a dice expression string such as "2d6-2".
  /// The JEP-based evaluator is stubbed; simple "XdY±Z" patterns are handled
  /// natively. For complex expressions a stub returning 0 is used.
  static int roll(String method) {
    if (method.isEmpty) return 0;

    // Normalize d% -> 1d100
    final String expr = method.replaceAll('d%', '1d100').trim();

    // Fast-path: plain integer
    final int? direct = int.tryParse(expr);
    if (direct != null) return direct;

    // Fast-path: simple NdM or NdM+K or NdM-K
    final RegExp simplePattern =
        RegExp(r'^(\d+)d(\d+)([+-]\d+)?$', caseSensitive: false);
    final Match? m = simplePattern.firstMatch(expr);
    if (m != null) {
      final int times = int.parse(m.group(1)!);
      final int sides = int.parse(m.group(2)!);
      final int modifier = m.group(3) != null ? int.parse(m.group(3)!) : 0;
      return _rollKeepTop(times, sides, times, 0) + modifier;
    }

    // stub: complex expressions (JEP-based: roll, top, reroll, list functions)
    // log: complex dice expression not fully supported: $method
    return 0;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Roll [times] 1d([sides]-[reroll]) + [reroll], keep the top [numToKeep].
  static int _rollKeepTop(int times, int sides, int numToKeep, int reroll) {
    if (sides <= 0) return 0;
    final List<int> rolls = List<int>.generate(
        times, (_) => _rng.nextInt(sides - reroll) + reroll + 1)
      ..sort();
    // keep the highest numToKeep
    int total = 0;
    final int skip = times - numToKeep;
    for (int i = skip; i < rolls.length; i++) {
      total += rolls[i];
    }
    return total;
  }

  // ---------------------------------------------------------------------------
  // Inner class equivalents (stubs – used by JEP extension, not translated)
  // ---------------------------------------------------------------------------

  // stub: Roll (PostfixMathCommand) – see roll(String method) above
  // stub: Top  (PostfixMathCommand)
  // stub: Reroll (PostfixMathCommand)
}
