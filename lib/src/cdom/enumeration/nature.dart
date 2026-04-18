// The nature of an ability grant — affects stacking and display.
enum Nature {
  normal,
  automatic,
  virtual,
  any;

  static Nature? getBestNature(Nature? nature1, Nature? nature2) {
    if (nature1 == null) return nature2;
    if (nature2 == null || nature2 == Nature.automatic) return nature1;
    if (nature1 == Nature.normal) return nature1;
    return nature2;
  }
}
