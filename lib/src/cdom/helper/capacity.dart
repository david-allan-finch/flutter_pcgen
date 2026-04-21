//
// Copyright (c) 2007 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.helper.Capacity
// Represents the carrying capacity of a container equipment item.
class Capacity {
  static const double unlimited = -1.0;
  static final Capacity any = Capacity(null, unlimited);

  final String? type;
  final double limit;

  Capacity(this.type, this.limit);

  double getCapacity() => limit;
  String? getType() => type;

  static Capacity getTotalCapacity(double capacity) => Capacity(null, capacity);

  @override
  String toString() {
    final typeStr = type ?? 'Total';
    final limitStr = limit == unlimited ? 'UNLIMITED' : limit.toString();
    return 'Capacity: $typeStr=$limitStr';
  }

  @override
  bool operator ==(Object other) {
    if (other is Capacity) {
      return type == other.type && limit == other.limit;
    }
    return false;
  }

  @override
  int get hashCode => (type?.hashCode ?? 0) ^ limit.hashCode;
}
