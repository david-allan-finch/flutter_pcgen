/// Mixin-like interface for tokens that provide compatibility with older
/// PCGen data file versions.
abstract interface class CompatibilityToken {
  int compatibilityLevel();
  int compatibilitySubLevel();
  int compatibilityPriority();
}
