//
// Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.core.PointBuyCost
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';

// Represents the cost (in points) to purchase a specific stat value in
// point-buy character creation.
final class PointBuyCost extends ConcretePrereqObject implements Loadable {
  String? _sourceUri;
  int _statValue = 0;
  int _buyCost = 0;

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String? source) => _sourceUri = source;

  @override
  String getDisplayName() => _statValue.toString();

  @override
  void setName(String name) {
    final parsed = int.tryParse(name);
    if (parsed == null) {
      throw ArgumentError('Name for a PointBuyCost must be an integer, found: $name');
    }
    _statValue = parsed;
  }

  @override
  String getKeyName() => _statValue.toString();

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  int getStatValue() => _statValue;

  void setBuyCost(int cost) => _buyCost = cost;
  int getBuyCost() => _buyCost;
}
