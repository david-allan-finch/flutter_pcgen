// Translation of pcgen.gui2.facade.CompanionFacadeDelegate

import '../../core/race.dart';
import '../../facade/core/companion_facade.dart';
import '../../facade/util/default_reference_facade.dart';
import '../../facade/util/reference_facade.dart';

/// A CompanionFacade implementation that delegates to another CompanionFacade.
/// All internal reference facades are themselves delegates to the underlying
/// CompanionFacade.
class CompanionFacadeDelegate implements CompanionFacade {
  CompanionFacade? _delegate;

  final _DelegateReferenceFacade<String> _nameDelegate =
      _DelegateReferenceFacade<String>();
  final _DelegateReferenceFacade<String> _fileDelegate =
      _DelegateReferenceFacade<String>(); // file path as String
  final _DelegateReferenceFacade<Race> _raceDelegate =
      _DelegateReferenceFacade<Race>();

  CompanionFacadeDelegate();

  void setCompanionFacade(CompanionFacade companionFacade) {
    _delegate = companionFacade;
    _nameDelegate.setDelegate(companionFacade.getNameRef());
    _fileDelegate.setDelegate(companionFacade.getFileRef());
    _raceDelegate.setDelegate(companionFacade.getRaceRef());
  }

  /// Returns the CompanionFacade backing this delegate.
  CompanionFacade? getDelegate() => _delegate;

  @override
  ReferenceFacade<String> getNameRef() => _nameDelegate;

  @override
  ReferenceFacade<String> getFileRef() => _fileDelegate;

  @override
  ReferenceFacade<Race> getRaceRef() => _raceDelegate;

  @override
  String? getCompanionType() => _delegate?.getCompanionType();
}

// ---------------------------------------------------------------------------

class _DelegateReferenceFacade<T> extends DefaultReferenceFacade<T> {
  ReferenceFacade<T>? _delegate;

  void setDelegate(ReferenceFacade<T>? newDelegate) {
    _delegate?.removeReferenceListener(_onRefChanged);
    _delegate = newDelegate;
    if (_delegate != null) {
      _delegate!.addReferenceListener(_onRefChanged);
      set(_delegate!.get());
    } else {
      set(null);
    }
  }

  void _onRefChanged(dynamic event) {
    set(event.newReference as T?);
  }
}
