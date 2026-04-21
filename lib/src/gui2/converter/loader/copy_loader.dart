// Translation of pcgen.gui2.converter.loader.CopyLoader

import '../conversion_decider.dart';
import '../loader.dart';

/// A [Loader] that copies each line verbatim without any token conversion.
/// Used for file types that do not require data transformation.
class CopyLoader implements Loader {
  /// The list-key under which files are stored on a Campaign.
  final dynamic listKey;

  CopyLoader(this.listKey);

  @override
  List<dynamic>? process(
    StringBuffer sb,
    int line,
    String lineString,
    ConversionDecider decider,
  ) {
    sb.write(lineString);
    return null;
  }

  @override
  List<dynamic> getFiles(dynamic campaign) {
    return campaign.getSafeListFor(listKey) as List<dynamic>;
  }
}
