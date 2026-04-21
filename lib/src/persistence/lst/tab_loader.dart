//
// Copyright 2013 (C) James Dempsey <jdempsey@users.sourceforge.net>
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
//
// Translation of pcgen.persistence.lst.TabLoader

import '../../rules/context/load_context.dart';
import 'simple_loader.dart';

/// Loads TabInfo objects from tab .lst files in the game mode directory.
///
/// TabInfo defines the tabs shown in the PCGen UI (e.g. Summary, Class, Skills).
/// Each line is a tab definition with TOKEN:value pairs.
class TabLoader extends SimpleLoader<dynamic> {
  TabLoader() : super(dynamic);

  @override
  dynamic getLoadable(dynamic context, String firstToken, Uri sourceUri) {
    if (firstToken.isEmpty) return null;
    // TODO: construct TabInfo via context and register it
    // Java: context.getReferenceContext().constructNowIfNecessary(TabInfo.class, name)
    return null;
  }
}
