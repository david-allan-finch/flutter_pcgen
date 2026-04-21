//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.persistence.lst.PointBuyLoader

import '../../core/point_buy_cost.dart';
import '../../core/point_buy_method.dart';
import '../../rules/context/load_context.dart';
import 'simple_loader.dart';

/// Loads PointBuyMethod and PointBuyCost objects from a pointbuy.lst file.
///
/// The first token of each line determines the object type:
///   POINTBUYMETHOD:<name> — a named point-buy method (e.g. "Standard (15)")
///   STAT:<stat>=<cost>    — a stat-to-cost mapping entry
class PointBuyLoader extends SimpleLoader<dynamic> {
  PointBuyLoader() : super(dynamic);

  @override
  dynamic getLoadable(dynamic context, String firstToken, Uri sourceUri) {
    final colonIdx = firstToken.indexOf(':');
    if (colonIdx <= 0) return null;

    final key = firstToken.substring(0, colonIdx).trim();
    final value = firstToken.substring(colonIdx + 1).trim();
    if (value.isEmpty) return null;

    switch (key) {
      case 'POINTBUYMETHOD':
        final method = PointBuyMethod();
        method.setName(value);
        method.setSourceURI(sourceUri.toString());
        if (context is LoadContext) {
          context.getReferenceContext().register(method);
        }
        return method;
      case 'STAT':
        // STAT:<statScore>=<pointCost>
        final eqIdx = value.indexOf('=');
        if (eqIdx > 0) {
          final score = int.tryParse(value.substring(0, eqIdx).trim());
          final cost = int.tryParse(value.substring(eqIdx + 1).trim());
          if (score != null && cost != null) {
            final pbc = PointBuyCost();
            pbc.setName(score.toString());
            pbc.setBuyCost(cost);
            return pbc;
          }
        }
        return null;
      default:
        return null;
    }
  }
}
