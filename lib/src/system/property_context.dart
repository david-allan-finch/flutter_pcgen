//
// Copyright 2009 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.system.PropertyContext

/// Hierarchical property storage. Child contexts share a parent's properties
/// but write into a namespaced sub-tree.
class PropertyContext {
  final String name;
  final PropertyContext? parent;
  final Map<String, String> _properties = {};

  PropertyContext(this.name, [this.parent]);

  String? getProperty(String key) =>
      _properties[key] ?? parent?.getProperty(key);

  void setProperty(String key, String value) => _properties[key] = value;

  bool hasProperty(String key) =>
      _properties.containsKey(key) || (parent?.hasProperty(key) ?? false);

  PropertyContext createChildContext(String childName) =>
      PropertyContext(childName, this);

  Map<String, String> toMap() {
    final map = <String, String>{};
    if (parent != null) map.addAll(parent!.toMap());
    map.addAll(_properties);
    return map;
  }
}
