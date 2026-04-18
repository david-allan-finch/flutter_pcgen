class ChangeEvent {
  final Object source;
  const ChangeEvent(this.source);
}

typedef ChangeListener = void Function(ChangeEvent event);
