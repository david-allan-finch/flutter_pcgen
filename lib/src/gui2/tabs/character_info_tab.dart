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
// Translation of pcgen.gui2.tabs.CharacterInfoTab

import 'tab_title.dart';

/// Interface that must be implemented by all tabs displaying character information.
///
/// The goal is to separate UI models from UI components. Models are cached per
/// character so switching between characters is fast — new models are not
/// created each time a character is selected.
abstract interface class CharacterInfoTab {
  /// Create the models needed to display [character] on this tab.
  ///
  /// Implementations MUST NOT make any UI changes here; this method only
  /// constructs model objects.
  ModelMap createModels(dynamic character);

  /// Attach the models in [models] to the UI components of this tab.
  void restoreModels(ModelMap models);

  /// Detach models / listeners from UI components and save any dirty state
  /// back into [models].
  void storeModels(ModelMap models);

  /// Returns the [TabTitle] used by [InfoTabbedPane] to render the tab header.
  TabTitle getTabTitle();
}

/// A typed map keyed by [Type], used to store and retrieve per-character
/// UI model objects without boxing into raw [Object] maps.
class ModelMap {
  final Map<Type, dynamic> _map = {};

  T? get<T>(Type key) => _map[key] as T?;

  void put<T>(Type key, T value) {
    _map[key] = value;
  }

  bool containsKey(Type key) => _map.containsKey(key);

  void clear() => _map.clear();
}
