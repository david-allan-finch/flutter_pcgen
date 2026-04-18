// Install destination for PCGen data packages.
enum Destination {
  data('DATA'),
  vendorData('VENDORDATA'),
  homebrewData('HOMEBREWDATA');

  final String text;
  const Destination(this.text);

  @override
  String toString() => text;
}
