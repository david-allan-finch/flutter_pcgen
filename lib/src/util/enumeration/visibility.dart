import 'view.dart';

enum Visibility {
  hidden('No'),
  defaultVisibility('Yes'),
  outputOnly('Export'),
  displayOnly('Display'),
  qualify('Qualify');

  final String text;

  const Visibility(this.text);

  @override
  String toString() => text;

  String getLSTFormat() => text.toUpperCase();

  bool isVisibleTo(View view) {
    return switch (view) {
      View.all => true,
      View.hiddenDisplay =>
        this == Visibility.hidden || this == Visibility.outputOnly,
      View.hiddenExport =>
        this == Visibility.hidden || this == Visibility.displayOnly,
      View.visibleExport =>
        this == Visibility.defaultVisibility || this == Visibility.outputOnly,
      View.visibleDisplay =>
        this == Visibility.defaultVisibility || this == Visibility.displayOnly,
    };
  }
}
