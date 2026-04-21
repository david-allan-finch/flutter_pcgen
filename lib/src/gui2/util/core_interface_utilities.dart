//
// Copyright (c) 2018-9 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.gui2.util.CoreInterfaceUtilities

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/facet_library.dart';
import 'package:flutter_pcgen/src/cdom/facet/load_context_facet.dart';
import 'package:flutter_pcgen/src/cdom/util/ccontrol.dart';
import 'package:flutter_pcgen/src/cdom/util/control_utilities.dart';
import 'package:flutter_pcgen/src/facade/util/reference_facade.dart';
import 'package:flutter_pcgen/src/facade/util/vetoable_reference_facade.dart';

/// Provides utility methods for obtaining Channels/Wrappers for the UI layer.
final class CoreInterfaceUtilities {
  CoreInterfaceUtilities._();

  static final LoadContextFacet _loadContextFacet =
      FacetLibrary.getFacet<LoadContextFacet>();

  /// Returns a [VetoableReferenceFacade] for the channel defined by [codeControl].
  ///
  /// [id] identifies the PlayerCharacter on which the channel lives.
  static VetoableReferenceFacade<T> getReferenceFacade<T>(
      CharID id, CControl codeControl) {
    final context = _loadContextFacet.get(id.datasetID)!;
    final channelName = ControlUtilities.getControlToken(context, codeControl);
    return context.variableContext.getGlobalChannel<T>(id, channelName)
        as VetoableReferenceFacade<T>;
  }

  /// Returns a read-only [ReferenceFacade] for the variable defined by [codeControl].
  static ReferenceFacade<dynamic> getReadOnlyFacadeByControl(
      CharID id, CControl codeControl) {
    final context = _loadContextFacet.get(id.datasetID)!;
    final variableName =
        ControlUtilities.getControlToken(context, codeControl);
    return getReadOnlyFacade(id, variableName);
  }

  /// Returns a read-only [ReferenceFacade] for the variable named [variableName].
  static ReferenceFacade<dynamic> getReadOnlyFacade(
      CharID id, String variableName) {
    final context = _loadContextFacet.get(id.datasetID)!;
    return context.variableContext.getGlobalWrapper(id, variableName);
  }
}
