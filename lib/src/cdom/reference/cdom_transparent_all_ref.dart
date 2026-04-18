import '../base/cdom_reference.dart';
import '../base/loadable.dart';
import '../enumeration/grouping_state.dart';
import 'cdom_group_ref.dart';
import 'reference_manufacturer.dart';
import 'transparent_reference.dart';

// A CDOMGroupRef representing ALL objects of a type; resolved transparently
// from a ReferenceManufacturer and can be re-resolved across campaign loads.
class CDOMTransparentAllRef<T extends Loadable> extends CDOMReference<T>
    implements CDOMGroupRef<T>, TransparentReference<T> {
  final Type _refClass;
  final String _formatRepresentation;
  CDOMGroupRef<T>? _subReference;

  CDOMTransparentAllRef(String formatRepresentation, Type objClass)
      : _refClass = objClass,
        _formatRepresentation = formatRepresentation,
        super('ALL');

  @override
  bool contains(T item) {
    if (_subReference == null) {
      throw StateError('Cannot ask for contains: ${getReferenceClass()} '
          'Reference ${getName()} has not been resolved');
    }
    return _subReference!.contains(item);
  }

  @override
  String getLSTformat([String? joinWith]) =>
      _subReference?.getLSTformat(joinWith) ?? 'ALL';

  @override
  void addResolution(T item) {
    throw StateError('Cannot resolve a Transparent Reference');
  }

  @override
  void resolve(ReferenceManufacturer<T> rm) {
    if (rm.getReferenceClass() == getReferenceClass()) {
      _subReference = rm.getAllReference();
    } else {
      throw ArgumentError('Cannot resolve a ${getReferenceClass()} '
          'Reference to a ${rm.getReferenceClass()}');
    }
  }

  @override
  List<T> getContainedObjects() => _subReference!.getContainedObjects();

  @override
  int getObjectCount() => _subReference?.getObjectCount() ?? 0;

  @override
  GroupingState getGroupingState() => GroupingState.allowsNone;

  @override
  String? getChoice() => _subReference?.getChoice();

  @override
  Type getReferenceClass() => _refClass;

  @override
  String getReferenceDescription() => _subReference == null
      ? 'ALL ${_refClass}'
      : _subReference!.getReferenceDescription();

  @override
  String getPersistentFormat() => _formatRepresentation;

  @override
  bool operator ==(Object other) {
    if (other is CDOMTransparentAllRef<T>) {
      return getReferenceClass() == other.getReferenceClass() &&
          getName() == other.getName();
    }
    return false;
  }

  @override
  int get hashCode => getReferenceClass().hashCode ^ getName().hashCode;
}
