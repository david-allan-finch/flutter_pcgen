enum View {
  all('ALL'),
  hiddenDisplay('HIDDEN_DISPLAY'),
  hiddenExport('HIDDEN_EXPORT'),
  visibleDisplay('VISIBLE_DISPLAY'),
  visibleExport('VISIBLE_EXPORT');

  final String text;

  const View(this.text);

  @override
  String toString() => text;

  static View? getViewFromName(String name) {
    for (final view in View.values) {
      if (view.text.toLowerCase() == name.toLowerCase()) return view;
    }
    return null;
  }
}
