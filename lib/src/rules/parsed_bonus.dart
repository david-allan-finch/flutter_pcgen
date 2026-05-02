/// Structured representation of a BONUS: token parsed from an LST file.
///
/// A BONUS line looks like:
///   BONUS:COMBAT|AC|DEX|TYPE=Ability
///   BONUS:SAVE|BASE.Fortitude|CL/2+2|TYPE=Base.REPLACE
///   BONUS:STAT|STR,CON|-2|PRETYPE:1,Undead
///
/// Structure: BONUS:<type>|<targets>|<formula>[|TYPE=<bonusType>][|PRE...]
library;

import 'package:flutter_pcgen/src/rules/formula_evaluator.dart';

// ---------------------------------------------------------------------------
// ParsedPrereq
// ---------------------------------------------------------------------------

enum PrereqOp {
  eq,   // PREVAREQ
  neq,  // PREVARNE
  gteq, // PREVARGTEQ
  gt,   // PREVARGTEQ (strict)
  lteq, // PREVARLT
  lt,   // PREVARLT (strict)
}

/// A single prerequisite condition attached to a BONUS or ability entry.
class ParsedPrereq {
  final String type;    // 'PREVAREQ', 'PREABILITY', 'PRETYPE', 'PREALIGN', etc.
  final String raw;     // raw value string for complex cases
  final bool negated;   // true if prefixed with '!'

  const ParsedPrereq({
    required this.type,
    required this.raw,
    this.negated = false,
  });

  /// Parse a single PRE token like 'PREVAREQ:SomeVar,0' or '!PRETYPE:1,Undead'.
  static ParsedPrereq? parse(String token) {
    var t = token.trim();
    final neg = t.startsWith('!');
    if (neg) t = t.substring(1);

    final colon = t.indexOf(':');
    if (colon < 0) return null;
    final type = t.substring(0, colon).toUpperCase();
    final raw  = t.substring(colon + 1);

    if (!type.startsWith('PRE')) return null;
    return ParsedPrereq(type: type, raw: raw, negated: neg);
  }

  /// Evaluate whether this prerequisite is satisfied by the given character state.
  bool evaluate(PrereqContext ctx) {
    bool result;
    switch (type) {
      case 'PREVAREQ':
        result = _evalVarOp(ctx, (a, b) => a == b);
        break;
      case 'PREVARNE':
        result = _evalVarOp(ctx, (a, b) => a != b);
        break;
      case 'PREVARGTEQ':
        result = _evalVarOp(ctx, (a, b) => a >= b);
        break;
      case 'PREVARGT':
        result = _evalVarOp(ctx, (a, b) => a > b);
        break;
      case 'PREVARLTEQ':
        result = _evalVarOp(ctx, (a, b) => a <= b);
        break;
      case 'PREVARLT':
        result = _evalVarOp(ctx, (a, b) => a < b);
        break;
      case 'PREALIGN':
        result = _evalAlign(ctx);
        break;
      case 'PRERACE':
        result = _evalRace(ctx);
        break;
      case 'PRETYPE':
        result = _evalType(ctx);
        break;
      case 'PREABILITY':
        result = _evalAbility(ctx);
        break;
      case 'PRECSKILL':
        result = _evalCSkill(ctx);
        break;
      case 'PRESKILL':
        result = _evalSkill(ctx);
        break;
      case 'PREPCLEVEL':
        result = _evalPcLevel(ctx);
        break;
      case 'PREBASESIZEEQ':
      case 'PREBASESIZELT':
      case 'PREBASESIZELTEQ':
      case 'PREBASESIZEGT':
      case 'PREBASESIZEGTEQ':
        // Size prerequisites — optimistically pass until size tracking is implemented
        result = true;
        break;
      case 'PRERULE':
        result = true; // game rule toggles — optimistically pass
        break;
      case 'PREMULT':
        result = _evalMult(ctx);
        break;
      case 'PRETOTALAB':
        // PRETOTALAB:N,minBAB — character BAB must be ≥ minBAB
        result = _evalTotalAb(ctx);
        break;
      case 'PRECLASS':
        // PRECLASS:N,ClassName=minLevel
        result = _evalPreClass(ctx);
        break;
      case 'PREFEAT':
        // PREFEAT:N,FeatName — reuse PREABILITY logic
        result = _evalAbility(ctx);
        break;
      case 'PREHANDSEQ':
      case 'PREHANDSGTEQ':
      case 'PREHANDSLT':
      case 'PRESPELLTYPE':
      case 'PRESPELLSCHOOL':
      case 'PRESPELLSCHOOLSUB':
      case 'PRESPELLCAST':
      case 'PRECAMPAIGN':
      case 'PREAGEGTEQ':
      case 'PREAGERANGE':
      case 'PREGENDER':
      case 'PREDEITY':
      case 'PREDEITYALIGN':
      case 'PREDOMAIN':
      case 'PREITEM':
      case 'PREARMORTYPE':
      case 'PREWEAPONPROF':
      case 'PREWIELD':
      case 'PRELEVEL':
      case 'PRELEVELMAX':
      case 'PRESREQ':
        result = true; // optimistic pass for unimplemented prereqs
        break;
      default:
        result = true; // unknown prereq: optimistically pass
    }
    return negated ? !result : result;
  }

  // ---- Evaluators ----------------------------------------------------------

  bool _evalVarOp(PrereqContext ctx, bool Function(double, double) op) {
    // raw: 'VarName,value'
    final comma = raw.indexOf(',');
    if (comma < 0) return true;
    final varName = raw.substring(0, comma).trim();
    final threshold = double.tryParse(raw.substring(comma + 1).trim()) ?? 0;
    final actual = ctx.getVariable(varName);
    return op(actual, threshold);
  }

  bool _evalAlign(PrereqContext ctx) {
    // raw: 'LG,NG,CG' — alignment abbreviation list
    final allowed = raw.split(',').map((s) => s.trim().toUpperCase()).toList();
    return allowed.contains(ctx.alignmentKey.toUpperCase());
  }

  bool _evalRace(PrereqContext ctx) {
    // raw: 'N,RaceName1,RaceName2'
    final parts = raw.split(',');
    if (parts.isEmpty) return false;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int matched = 0;
    for (int i = 1; i < parts.length; i++) {
      final rn = parts[i].trim().toLowerCase();
      if (ctx.raceKey.toLowerCase() == rn || ctx.raceKey.toLowerCase().contains(rn)) {
        matched++;
      }
    }
    return matched >= needed;
  }

  bool _evalType(PrereqContext ctx) {
    // raw: 'N,Type1,Type2'
    final parts = raw.split(',');
    if (parts.isEmpty) return false;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int matched = 0;
    for (int i = 1; i < parts.length; i++) {
      final typeName = parts[i].trim();
      if (ctx.objectTypes.any((t) => t.equalsIgnoreCase(typeName))) matched++;
    }
    return matched >= needed;
  }

  bool _evalAbility(PrereqContext ctx) {
    // raw: 'N,CATEGORY=cat,AbilityName1,...'  or  'N,AbilityName'
    final parts = raw.split(',');
    if (parts.isEmpty) return false;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    String? category;
    final names = <String>[];
    for (int i = 1; i < parts.length; i++) {
      final p = parts[i].trim();
      if (p.toUpperCase().startsWith('CATEGORY=')) {
        category = p.substring(9);
      } else if (!p.toUpperCase().startsWith('TYPE.')) {
        names.add(p.toLowerCase());
      }
    }
    int matched = 0;
    for (final storedKey in ctx.selectedAbilityKeys(category)) {
      // storedKey may be "AbilityName|Choice" — compare using base key only
      final baseKey = storedKey.contains('|')
          ? storedKey.substring(0, storedKey.indexOf('|')).toLowerCase()
          : storedKey.toLowerCase();
      if (names.any((n) =>
          baseKey == n ||
          baseKey.startsWith(n) ||
          n.startsWith(baseKey))) {
        matched++;
      }
    }
    return matched >= needed;
  }

  bool _evalCSkill(PrereqContext ctx) {
    // PRECSKILL:1,SkillName — skill must be a class skill
    final parts = raw.split(',');
    if (parts.length < 2) return false;
    final skillName = parts.skip(1).join(',').trim().toLowerCase();
    return ctx.classSkillNames.any((s) => s.toLowerCase() == skillName);
  }

  bool _evalSkill(PrereqContext ctx) {
    // PRESKILL:1,SkillName=ranks
    final parts = raw.split(',');
    if (parts.length < 2) return true;
    for (int i = 1; i < parts.length; i++) {
      final eq = parts[i].indexOf('=');
      if (eq < 0) continue;
      final skillName = parts[i].substring(0, eq).trim().toLowerCase();
      final needed = double.tryParse(parts[i].substring(eq + 1).trim()) ?? 0;
      final actual = ctx.getSkillRanks(skillName);
      if (actual < needed) return false;
    }
    return true;
  }

  bool _evalPcLevel(PrereqContext ctx) {
    // PREPCLEVEL:N — total level >= N
    final needed = int.tryParse(raw.trim()) ?? 0;
    return ctx.totalLevel >= needed;
  }

  bool _evalTotalAb(PrereqContext ctx) {
    // PRETOTALAB:N,minBAB — raw = 'N,minBAB'
    final comma = raw.indexOf(',');
    if (comma < 0) return true;
    final minBab = double.tryParse(raw.substring(comma + 1).trim()) ?? 0;
    // Try BAB variable first, fall back to totalLevel as a proxy.
    final bab = ctx.getVariable('BAB');
    if (bab > 0) return bab >= minBab;
    return ctx.totalLevel.toDouble() >= minBab - 1;
  }

  bool _evalPreClass(PrereqContext ctx) {
    // PRECLASS:N,ClassName=minLevel[,ClassName2=minLevel2]
    // We don't have class-level data in PrereqContext, so we check whether the
    // character has any class-level by looking at getVariable('CL.<name>').
    // If still 0, optimistically pass (conservative approach would fail).
    final parts = raw.split(',');
    if (parts.isEmpty) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int met = 0;
    for (int i = 1; i < parts.length; i++) {
      final eq = parts[i].indexOf('=');
      if (eq < 0) continue;
      final className = parts[i].substring(0, eq).trim();
      final minLvl = double.tryParse(parts[i].substring(eq + 1).trim()) ?? 1;
      final actual = ctx.getVariable('CL.$className');
      if (actual >= minLvl) met++;
    }
    if (met >= needed) return true;
    // Optimistic pass if we can't determine class levels.
    return true;
  }

  bool _evalMult(PrereqContext ctx) {
    // PREMULT:N,[prereq1],[prereq2] — N of the sub-prereqs must pass
    final parts = raw.split(',');
    if (parts.isEmpty) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int passed = 0;
    for (int i = 1; i < parts.length; i++) {
      final sub = ParsedPrereq.parse(parts[i].trim().replaceAll('[', '').replaceAll(']', ''));
      if (sub != null && sub.evaluate(ctx)) passed++;
    }
    return passed >= needed;
  }
}

extension on String {
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}

// ---------------------------------------------------------------------------
// PrereqContext — what the prereq evaluator can query
// ---------------------------------------------------------------------------

abstract class PrereqContext {
  String get alignmentKey;
  String get raceKey;
  int get totalLevel;
  List<String> get objectTypes; // for PRETYPE — types of the current item/object
  List<String> get classSkillNames;
  List<String> selectedAbilityKeys([String? category]);
  double getVariable(String name);
  double getSkillRanks(String skillName);
}

// ---------------------------------------------------------------------------
// ParsedBonus
// ---------------------------------------------------------------------------

/// A stacking type for BONUS values.
enum BonusStack {
  normal,  // same TYPE doesn't stack (only highest applies)
  stack,   // explicitly stacks (TYPE=xxx.STACK)
  replace, // highest replaces (TYPE=xxx.REPLACE)
}

class ParsedBonus {
  /// BONUS category: COMBAT, SAVE, SKILL, STAT, VAR, HP, ABILITYPOOL, etc.
  final String category;

  /// Target sub-keys within the category, e.g. ['AC'], ['Fortitude'], ['STR','CON']
  final List<String> targets;

  /// Formula string to evaluate.
  final String formula;

  /// Bonus type tag (e.g. 'Armor', 'Enhancement', 'Racial', 'Base').
  /// Empty string = untyped (always stacks).
  final String bonusType;

  final BonusStack stack;

  /// Prerequisite conditions that must all pass for this bonus to apply.
  final List<ParsedPrereq> prereqs;

  const ParsedBonus({
    required this.category,
    required this.targets,
    required this.formula,
    this.bonusType = '',
    this.stack = BonusStack.normal,
    this.prereqs = const [],
  });

  /// Parse a BONUS: token value (everything after 'BONUS:').
  ///
  /// Format: category|targets|formula[|TYPE=bonusType][|PRExxx:...]
  static ParsedBonus? parse(String value) {
    final parts = value.split('|');
    if (parts.length < 3) return null;

    final category = parts[0].trim().toUpperCase();
    final targets  = parts[1].split(',').map((s) => s.trim()).toList();
    final formula  = parts[2].trim();

    String bonusType = '';
    BonusStack stack = BonusStack.normal;
    final prereqs = <ParsedPrereq>[];

    for (int i = 3; i < parts.length; i++) {
      final p = parts[i].trim();
      if (p.toUpperCase().startsWith('TYPE=')) {
        final tv = p.substring(5);
        if (tv.toUpperCase().endsWith('.STACK')) {
          bonusType = tv.substring(0, tv.length - 6);
          stack = BonusStack.stack;
        } else if (tv.toUpperCase().endsWith('.REPLACE')) {
          bonusType = tv.substring(0, tv.length - 8);
          stack = BonusStack.replace;
        } else {
          bonusType = tv;
        }
      } else if (p.toUpperCase().startsWith('PRE') || p.startsWith('!PRE')) {
        final prereq = ParsedPrereq.parse(p);
        if (prereq != null) prereqs.add(prereq);
      }
    }

    return ParsedBonus(
      category: category,
      targets: targets,
      formula: formula,
      bonusType: bonusType,
      stack: stack,
      prereqs: prereqs,
    );
  }

  /// Evaluate the bonus value given a [FormulaContext].
  double evaluate(FormulaContext ctx) =>
      FormulaEvaluator.evaluate(formula, ctx);

  /// Check all prerequisites against the given context.
  bool checkPrereqs(PrereqContext ctx) =>
      prereqs.every((p) => p.evaluate(ctx));

  @override
  String toString() =>
      'ParsedBonus($category|${targets.join(",")}|$formula'
      '${bonusType.isNotEmpty ? "|TYPE=$bonusType" : ""})';
}
