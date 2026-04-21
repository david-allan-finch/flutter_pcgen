// Translation of pcgen.gui2.util.event.ListDataAdapter

/// Adapter that listens to list data events and forwards to callbacks.
class ListDataAdapter {
  final void Function(int index0, int index1)? onIntervalAdded;
  final void Function(int index0, int index1)? onIntervalRemoved;
  final void Function(int index0, int index1)? onContentsChanged;

  ListDataAdapter({
    this.onIntervalAdded,
    this.onIntervalRemoved,
    this.onContentsChanged,
  });

  void intervalAdded(dynamic event) {
    onIntervalAdded?.call(event.index0 as int, event.index1 as int);
  }

  void intervalRemoved(dynamic event) {
    onIntervalRemoved?.call(event.index0 as int, event.index1 as int);
  }

  void contentsChanged(dynamic event) {
    onContentsChanged?.call(event.index0 as int, event.index1 as int);
  }
}
