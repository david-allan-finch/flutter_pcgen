// Translation of pcgen.io.PCGFile

/// Utility methods for working with PCG character files.
class PCGFile {
  static const String pcgExtension = '.pcg';
  static const String pccExtension = '.pcc';

  PCGFile._();

  static bool isPCGFile(String path) =>
      path.toLowerCase().endsWith(pcgExtension);

  static bool isPCCFile(String path) =>
      path.toLowerCase().endsWith(pccExtension);
}
