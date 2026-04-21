//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.system.PropertyContextFactory

import 'package:flutter_pcgen/src/system/property_context.dart';

/// Creates and manages PropertyContext instances, loading/saving them
/// from a specified directory.
class PropertyContextFactory {
  static PropertyContextFactory? _defaultFactory;

  final String dir;
  final Map<String, PropertyContext> _contextMap = {};

  PropertyContextFactory(this.dir);

  static PropertyContextFactory? getDefaultFactory() => _defaultFactory;

  static void setDefaultFactory(String dir) {
    _defaultFactory = PropertyContextFactory(dir);
  }

  void registerAndLoadPropertyContext(PropertyContext context) {
    _contextMap[context.name] = context;
    // TODO: load properties from file
  }

  PropertyContext? getPropertyContext(String name) => _contextMap[name];
}
