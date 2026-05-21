// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.PointBuyLoader

import 'package:flutter_pcgen/src/core/point_buy_cost.dart';
import 'package:flutter_pcgen/src/core/point_buy_method.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_line_file_loader.dart';

/// Loads PointBuyMethod and PointBuyCost objects from a pointbuymethods.lst file.
///
/// Actual file format (tab-delimited sub-tokens):
///   STAT:8       COST:8
///   STAT:9       COST:9
///   METHOD:Standard Campaign   POINTS:80
///
/// Each block of STAT lines belongs to the most-recent METHOD header.
/// Multiple METHOD sections may appear in one file.
class PointBuyLoader extends LstLineFileLoader {
  PointBuyMethod? _currentMethod;
  final List<PointBuyMethod> _methods = [];

  List<PointBuyMethod> get methods => List.unmodifiable(_methods);

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final firstColonIdx = lstLine.indexOf(':');
    if (firstColonIdx <= 0) return;

    final lineKey = lstLine.substring(0, firstColonIdx).trim().toUpperCase();

    if (lineKey == 'METHOD') {
      // METHOD:Name  POINTS:n
      // Start a new point-buy method
      final subs = _subtokens(lstLine);
      final name   = subs['METHOD'] ?? '';
      final points = subs['POINTS'] ?? '0';
      if (name.isEmpty) return;

      final method = PointBuyMethod();
      method.setName(name);
      method.setPointFormula(points);
      method.setSourceURI(sourceUri.toString());
      if (context is LoadContext) {
        context.getReferenceContext().register(method);
      }
      _currentMethod = method;
      _methods.add(method);
      return;
    }

    if (lineKey == 'STAT') {
      // STAT:score  COST:cost
      final subs  = _subtokens(lstLine);
      final score = int.tryParse(subs['STAT'] ?? '');
      final cost  = int.tryParse(subs['COST'] ?? '');
      if (score == null || cost == null) return;

      final pbc = PointBuyCost();
      pbc.setName(score.toString());
      pbc.setBuyCost(cost);
      // Associate with current method if available
      _currentMethod?.addPointBuyCost(pbc);
      return;
    }

    // Also accept the older POINTBUYMETHOD: tag for backward compatibility
    if (lineKey == 'POINTBUYMETHOD') {
      final value = lstLine.substring(firstColonIdx + 1).trim();
      final method = PointBuyMethod();
      method.setName(value);
      method.setSourceURI(sourceUri.toString());
      _currentMethod = method;
      _methods.add(method);
    }
  }

  /// Parses all tab-delimited KEY:value pairs from [line] into a map.
  static Map<String, String> _subtokens(String line) {
    final m = <String, String>{};
    for (final tok in line.split('\t')) {
      final t = tok.trim();
      final c = t.indexOf(':');
      if (c <= 0) continue;
      m[t.substring(0, c).toUpperCase()] = t.substring(c + 1).trim();
    }
    return m;
  }
}
