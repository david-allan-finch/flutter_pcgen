// Translation of pcgen.gui2.UIContext

import '../facade/util/default_reference_facade.dart';
import '../facade/core/source_selection_facade.dart';

/// Stores the source selection information currently identified as being
/// loaded by the UI.
class UIContext {
  final DefaultReferenceFacade<SourceSelectionFacade> _currentSourceSelection;

  UIContext() : _currentSourceSelection = DefaultReferenceFacade<SourceSelectionFacade>();

  DefaultReferenceFacade<SourceSelectionFacade> getCurrentSourceSelectionRef() =>
      _currentSourceSelection;
}
