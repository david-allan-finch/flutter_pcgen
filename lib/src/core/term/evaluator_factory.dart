// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EvaluatorFactory

import 'dart:collection';

import 'term_evaluator.dart';
import 'term_evaluator_builder.dart';
import 'term_evaluator_builder_eq_var.dart';
import 'term_evaluator_builder_pc_stat.dart';
import 'term_evaluator_builder_pc_var.dart';
import 'term_evaulator_exception.dart';

/// Factory that maps term strings to TermEvaluator instances.
///
/// Two singletons are provided: [pc] for PC-context terms and [eq] for
/// equipment-context terms. Evaluators are cached after first construction.
class EvaluatorFactory {
  late final RegExp _internalVarPattern;
  late final Map<String, TermEvaluatorBuilder> _builderStore;

  final Map<String, TermEvaluator> _srcNeutralStore = {};
  final Map<String, Map<String, TermEvaluator>> _srcDependantStore = {};

  static late final EvaluatorFactory pc;
  static late final EvaluatorFactory eq;

  /// Initialises the two factory singletons. Must be called after game data
  /// (stat abbreviations) has been loaded.
  static void initialise(List<String> statKeys) {
    final pcBuilders = [
      ...TermEvaluatorBuilderPCVar.values,
      _makeStatBuilder(statKeys),
    ];
    pc = EvaluatorFactory._fromBuilders(pcBuilders);
    eq = EvaluatorFactory._fromBuilders(TermEvaluatorBuilderEQVar.values);
  }

  EvaluatorFactory._fromBuilders(List<TermEvaluatorBuilder> builders) {
    _builderStore = SplayTreeMap();
    final sb = StringBuffer('^(');
    bool first = true;
    for (final b in builders) {
      if (!first) sb.write('|');
      first = false;
      sb.write(b.getTermConstructorPattern());
      for (final key in b.getTermConstructorKeys()) {
        _builderStore[key] = b;
      }
    }
    sb.write(')');
    _internalVarPattern = RegExp(sb.toString());
  }

  static TermEvaluatorBuilder _makeStatBuilder(List<String> statKeys) {
    final pattern = '(?:${statKeys.join('|')})';
    return TermEvaluatorBuilderPCStat(pattern, statKeys, false);
  }

  TermEvaluator? _makeTermEvaluator(String term, String source) {
    final match = _internalVarPattern.firstMatch(term);
    if (match == null) return null;
    final matched = match.group(1)!;
    final builder = _builderStore[matched];
    if (builder == null) return null;
    try {
      if (builder.isEntireTerm() && term.length != matched.length) return null;
      return builder.getTermEvaluator(term, source, matched);
    } on TermEvaulatorException catch (_) {
      return null;
    }
  }

  /// Returns a (possibly cached) TermEvaluator for [term] evaluated in [source].
  TermEvaluator? getTermEvaluator(String term, String source) {
    final inner = _srcDependantStore[term];
    if (inner != null) {
      final cached = inner[source];
      if (cached != null) return cached;
    } else {
      final cached = _srcNeutralStore[term];
      if (cached != null) return cached;
    }

    final evaluator = _makeTermEvaluator(term, source);
    if (evaluator == null) return null;

    if (evaluator.isSourceDependant()) {
      (_srcDependantStore[term] ??= {})[source] = evaluator;
    } else {
      _srcNeutralStore[term] = evaluator;
    }
    return evaluator;
  }
}
