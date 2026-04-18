import '../../rules/context/load_context.dart';

// Loader for Code Control Definitions.
class CodeControlLoader {
  void parseLine(LoadContext context, String inputLine, String sourceURI) {
    final sepLoc = inputLine.indexOf('\t');
    if (sepLoc != -1) {
      // log: Unsure what to do with line with multiple tokens
      return;
    }
    final refContext = context.getReferenceContext();
    final controller =
        refContext.constructNowIfNecessary(dynamic, 'Controller'); // CodeControl
    // stub — LstUtils.processToken not yet translated
  }
}
