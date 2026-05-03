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
      case 'PREVAREQ':        result = _evalVarOp(ctx, (a, b) => a == b); break;
      case 'PREVARNE':        result = _evalVarOp(ctx, (a, b) => a != b); break;
      case 'PREVARGTEQ':      result = _evalVarOp(ctx, (a, b) => a >= b); break;
      case 'PREVARGT':        result = _evalVarOp(ctx, (a, b) => a > b);  break;
      case 'PREVARLTEQ':      result = _evalVarOp(ctx, (a, b) => a <= b); break;
      case 'PREVARLT':        result = _evalVarOp(ctx, (a, b) => a < b);  break;
      case 'PREALIGN':        result = _evalAlign(ctx);    break;
      case 'PRERACE':         result = _evalRace(ctx);     break;
      case 'PRETYPE':         result = _evalType(ctx);     break;
      case 'PREABILITY':
      case 'PREFEAT':         result = _evalAbility(ctx);  break;
      case 'PRECSKILL':       result = _evalCSkill(ctx);   break;
      case 'PRESKILL':        result = _evalSkill(ctx);    break;
      case 'PREPCLEVEL':      result = _evalPcLevel(ctx);  break;
      case 'PREMULT':         result = _evalMult(ctx);     break;
      case 'PRETOTALAB':      result = _evalTotalAb(ctx);  break;
      case 'PRECLASS':        result = _evalPreClass(ctx); break;
      case 'PRESTAT':         result = _evalPreStat(ctx);  break;
      case 'PREDEITY':        result = _evalPreDeity(ctx); break;
      case 'PREDOMAIN':       result = _evalPreDomain(ctx); break;
      case 'PRELANG':         result = _evalPreLang(ctx);  break;
      case 'PREVISION':       result = _evalPreVision(ctx); break;
      case 'PRETEMPLATE':     result = _evalPreTemplate(ctx); break;
      case 'PREWEAPONPROF':   result = _evalPreWeaponProf(ctx); break;
      case 'PRESIZEEQ':       result = _evalPreSize(ctx, (a, b) => a == b); break;
      case 'PRESIZEGTEQ':     result = _evalPreSize(ctx, (a, b) => _sizeOrdinal(a) >= _sizeOrdinal(b)); break;
      case 'PRESIZELT':       result = _evalPreSize(ctx, (a, b) => _sizeOrdinal(a) <  _sizeOrdinal(b)); break;
      case 'PRESIZELTEQ':     result = _evalPreSize(ctx, (a, b) => _sizeOrdinal(a) <= _sizeOrdinal(b)); break;
      case 'PRESIZENEQ':      result = _evalPreSize(ctx, (a, b) => a != b); break;
      case 'PRERACETYPE':     result = _evalPreRaceType(ctx); break;
      case 'PRECHECK':
      case 'PRECHECKBASE':    result = _evalPreCheck(ctx); break;
      case 'PREBASESIZEEQ':
      case 'PREBASESIZELT':
      case 'PREBASESIZELTEQ':
      case 'PREBASESIZEGT':
      case 'PREBASESIZEGTEQ': result = true; break;
      case 'PRERULE':         result = true; break;
      case 'PREHANDSEQ':
      case 'PREHANDSGTEQ':
      case 'PREHANDSLT':
      case 'PRESPELLTYPE':
      case 'PRESPELLSCHOOL':
      case 'PRESPELLSCHOOLSUB':
      case 'PRESPELLCAST':
      case 'PRESPELL':
      case 'PRESPELLBOOK':
      case 'PRESPELLDESCRIPTOR':
      case 'PRECAMPAIGN':
      case 'PREAGEGTEQ':
      case 'PREAGERANGE':
      case 'PREGENDER':
      case 'PREDEITYALIGN':
      case 'PREITEM':
      case 'PREARMORTYPE':
      case 'PREPROFWITHARMOR':
      case 'PREPROFWITHSHIELD':
      case 'PREWIELD':
      case 'PRELEVEL':
      case 'PRELEVELMAX':
      case 'PRESREQ':
      case 'PREEQUIP':
      case 'PREMOVE':
      case 'PREREGION':
      case 'PREDR':
      case 'PRESUBCLASS':
      case 'PREAGESET':
      case 'PREHD':
      case 'PREHP':
      case 'PRESRGTEQ':
      case 'PRESRLT':
      case 'PRETEXT':         result = true; break;
      default:                result = true; break;
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
    // Class levels are exposed as CL.<classKey> and CL.<displayName> variables.
    final parts = raw.split(',');
    if (parts.isEmpty) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    // If no class levels at all recorded yet, optimistically pass
    // (character creation before any class is chosen).
    if (ctx.totalLevel == 0) return true;
    int met = 0;
    for (int i = 1; i < parts.length; i++) {
      final eq = parts[i].indexOf('=');
      if (eq < 0) continue;
      final className = parts[i].substring(0, eq).trim();
      final minLvl = double.tryParse(parts[i].substring(eq + 1).trim()) ?? 1;
      final actual = ctx.getVariable('CL.$className');
      if (actual >= minLvl) met++;
    }
    return met >= needed;
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

  bool _evalPreStat(PrereqContext ctx) {
    // PRESTAT:N,STR=13,DEX=15 — N stats must meet their minimums
    final parts = raw.split(',');
    if (parts.isEmpty) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int met = 0;
    for (int i = 1; i < parts.length; i++) {
      final eq = parts[i].indexOf('=');
      if (eq < 0) continue;
      final statAbb = parts[i].substring(0, eq).trim().toUpperCase();
      final minVal  = int.tryParse(parts[i].substring(eq + 1).trim()) ?? 0;
      if (ctx.getStatScore(statAbb) >= minVal) met++;
    }
    return met >= needed;
  }

  bool _evalPreDeity(PrereqContext ctx) {
    final parts = raw.split(',');
    if (parts.length < 2) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int met = 0;
    for (int i = 1; i < parts.length; i++) {
      if (ctx.deityKey.toLowerCase() == parts[i].trim().toLowerCase()) met++;
    }
    return met >= needed;
  }

  bool _evalPreDomain(PrereqContext ctx) {
    final parts = raw.split(',');
    if (parts.length < 2) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int met = 0;
    final domains = ctx.domainKeys.map((d) => d.toLowerCase()).toList();
    for (int i = 1; i < parts.length; i++) {
      if (domains.contains(parts[i].trim().toLowerCase())) met++;
    }
    return met >= needed;
  }

  bool _evalPreLang(PrereqContext ctx) {
    final parts = raw.split(',');
    if (parts.length < 2) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int met = 0;
    final langs = ctx.languageNames.map((l) => l.toLowerCase()).toList();
    for (int i = 1; i < parts.length; i++) {
      if (langs.contains(parts[i].trim().toLowerCase())) met++;
    }
    return met >= needed;
  }

  bool _evalPreVision(PrereqContext ctx) {
    final parts = raw.split(',');
    if (parts.length < 2) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int met = 0;
    final visions = ctx.visionTypes.map((v) => v.toLowerCase()).toList();
    for (int i = 1; i < parts.length; i++) {
      final vt = parts[i].trim().toLowerCase().replaceAll(RegExp(r'\s*\(.*\)'), '');
      if (visions.any((v) => v.startsWith(vt))) met++;
    }
    return met >= needed;
  }

  bool _evalPreTemplate(PrereqContext ctx) {
    final parts = raw.split(',');
    if (parts.length < 2) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int met = 0;
    final tpls = ctx.templateKeys.map((t) => t.toLowerCase()).toList();
    for (int i = 1; i < parts.length; i++) {
      if (tpls.contains(parts[i].trim().toLowerCase())) met++;
    }
    return met >= needed;
  }

  bool _evalPreWeaponProf(PrereqContext ctx) {
    final parts = raw.split(',');
    if (parts.length < 2) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    int met = 0;
    final profs = ctx.weaponProficiencies.map((p) => p.toLowerCase()).toList();
    for (int i = 1; i < parts.length; i++) {
      final wp = parts[i].trim().toLowerCase();
      if (wp.startsWith('type.')) {
        met++; // TYPE.Simple etc — optimistic
      } else if (profs.contains(wp)) {
        met++;
      }
    }
    return met >= needed;
  }

  static const _sizeOrder = ['F', 'D', 'T', 'S', 'M', 'L', 'H', 'G', 'C'];
  static int _sizeOrdinal(String s) {
    final idx = _sizeOrder.indexOf(s.trim().toUpperCase());
    return idx < 0 ? 4 : idx; // default to M=4
  }

  bool _evalPreSize(PrereqContext ctx, bool Function(String, String) op) =>
      op(ctx.sizeKey, raw.trim());

  bool _evalPreRaceType(PrereqContext ctx) {
    final parts = raw.split(',');
    if (parts.length < 2) return true;
    final needed = int.tryParse(parts[0].trim()) ?? 1;
    final raceTypes = ctx.objectTypes
        .where((t) => t.startsWith('RACETYPE:'))
        .map((t) => t.substring(9).toLowerCase())
        .toList();
    int met = 0;
    for (int i = 1; i < parts.length; i++) {
      if (raceTypes.contains(parts[i].trim().toLowerCase())) met++;
    }
    return met >= needed;
  }

  bool _evalPreCheck(PrereqContext ctx) => true; // optimistic
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
  int getStatScore(String statAbb);
  String get deityKey;
  List<String> get domainKeys;
  List<String> get languageNames;
  List<String> get visionTypes;
  List<String> get templateKeys;
  List<String> get weaponProficiencies;
  String get sizeKey; // e.g. 'M', 'S', 'L'
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
