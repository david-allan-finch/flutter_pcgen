// Represents the Campaign data-set quality statuses available in PCGen.
enum Status {
  release,
  alpha,
  beta,
  testOnly;

  static Status getDefaultValue() => Status.release;

  @override
  String toString() {
    switch (this) {
      case Status.release: return 'Release';
      case Status.alpha: return 'Alpha';
      case Status.beta: return 'Beta';
      case Status.testOnly: return 'Test Only';
    }
  }
}
