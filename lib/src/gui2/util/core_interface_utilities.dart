// Translation of pcgen.gui2.util.CoreInterfaceUtilities

import '../../cdom/enumeration/char_id.dart';
import '../../cdom/facet/facet_library.dart';
import '../../cdom/facet/load_context_facet.dart';
import '../../cdom/util/c_control.dart';
import '../../cdom/util/control_utilities.dart';
import '../../facade/util/reference_facade.dart';
import '../../facade/util/vetoable_reference_facade.dart';

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
