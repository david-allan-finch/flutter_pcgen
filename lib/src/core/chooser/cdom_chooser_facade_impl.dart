// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.core.chooser.CDOMChooserFacadeImpl

/// A ChooserFacade implementation backed by pre-built available/selected lists.
///
/// The UI layer calls [addSelected]/[removeSelected] to build the selection,
/// then [commit] to finalize it. [getFinalSelected] returns the committed list.
class CDOMChooserFacadeImpl<T> {
  final String name;
  final List<T> origAvailable;
  final List<T> origSelected;
  final int maxNewSelections;

  final List<T> _available = [];
  final List<T> _selected = [];
  late List<T> _finalSelected;

  bool dupsAllowed = false;
  bool requireCompleteSelection = false;
  bool preferRadioSelection = false;
  bool userInput = false;
  dynamic infoFactory;

  final String availableTableTitle;
  final String availableTableTypeNameTitle;
  final String selectedTableTitle;
  final String selectionCountName;
  final String addButtonName;
  final String removeButtonName;
  final String? stringDelimiter;

  CDOMChooserFacadeImpl(
    this.name,
    List<T> available,
    List<T> selected,
    this.maxNewSelections, {
    this.availableTableTitle = 'Available',
    this.availableTableTypeNameTitle = 'Type/Name',
    this.selectedTableTitle = 'Selected',
    this.selectionCountName = 'Remaining',
    this.addButtonName = 'Add',
    this.removeButtonName = 'Remove',
    this.stringDelimiter,
  })  : origAvailable = List<T>.from(available),
        origSelected = List<T>.from(selected) {
    _available.addAll(available);
    _selected.addAll(selected);
    _finalSelected = List<T>.from(selected);
  }

  List<T> getAvailableList() => List.unmodifiable(_available);
  List<T> getSelectedList() => List.unmodifiable(_selected);

  int getRemainingSelections() =>
      maxNewSelections - (_selected.length - origSelected.length);

  void addSelected(T item) {
    if (getRemainingSelections() <= 0) return;
    if (!dupsAllowed && _selected.contains(item)) return;
    _selected.add(item);
    if (!dupsAllowed) _available.remove(item);
  }

  void removeSelected(T item) {
    if (_selected.remove(item)) {
      if (!dupsAllowed) _available.add(item);
    }
  }

  void commit() {
    _finalSelected = List<T>.from(_selected);
  }

  void rollback() {
    _selected.clear();
    _selected.addAll(origSelected);
    _available.clear();
    _available.addAll(origAvailable);
  }

  List<T> getFinalSelected() => _finalSelected;

  void setAllowsDups(bool value) => dupsAllowed = value;
  void setRequireCompleteSelection(bool value) =>
      requireCompleteSelection = value;
  void setPreferRadioSelection(bool value) => preferRadioSelection = value;
  void setUserInput(bool value) => userInput = value;
  void setInfoFactory(dynamic factory) => infoFactory = factory;
}
