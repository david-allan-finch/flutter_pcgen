import 'abstract_reference_facade.dart';
import 'reference_facade.dart';

/// A [WriteableReferenceFacade] that allows registered functions to veto
/// proposed changes. A veto function returns [true] to block the change.
class VetoableReferenceFacade<T> extends AbstractReferenceFacade<T> {
  T? _object;
  final List<bool Function(T? oldValue, T? newValue)> _vetoFunctions = [];

  VetoableReferenceFacade([this._object]);

  @override
  T? get() => _object;

  void addVetoToChannel(bool Function(T? oldValue, T? newValue) function) {
    _vetoFunctions.add(function);
  }

  void set(T? newValue) {
    for (final veto in _vetoFunctions) {
      if (veto(_object, newValue)) return; // vetoed
    }
    final old = _object;
    _object = newValue;
    fireReferenceChangedEvent(this, old, newValue);
  }
}
