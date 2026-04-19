// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.DynamicLoader

import '../../persistence/lst/simple_loader.dart';
import '../../rules/context/load_context.dart';

/// Loads DYNAMIC LST files into [Dynamic]-category objects.
///
/// Each line has the form  DYNAMICSCOPE_KEY:ObjectName<tab>TOKEN:VALUE...
/// Translation of pcgen.rules.persistence.DynamicLoader.
class DynamicLoader extends SimpleLoader<dynamic> {
  DynamicLoader() : super(dynamic);

  @override
  dynamic getLoadable(dynamic context, String firstToken, Uri sourceUri) {
    final colonLoc = firstToken.indexOf(':');
    if (colonLoc == -1) {
      print("ERROR: Invalid Token - does not contain a colon: "
          "'$firstToken' in $sourceUri");
      return null;
    }
    if (colonLoc == 0) {
      print("ERROR: Invalid Token - starts with a colon: "
          "'$firstToken' in $sourceUri");
      return null;
    }
    if (colonLoc == firstToken.length - 1) {
      print("ERROR: Invalid Token - ends with a colon (no value): "
          "'$firstToken' in $sourceUri");
      return null;
    }

    final key = firstToken.substring(0, colonLoc);
    final name = firstToken.substring(colonLoc + 1);

    if (name.isEmpty) {
      print("ERROR: Invalid Token '$key' had no value in $sourceUri");
      return null;
    }

    // TODO: look up DynamicCategory by key in context.getReferenceContext(),
    //       construct / retrieve Dynamic object and import into the context.
    //       Requires Dynamic and DynamicCategory types to be ported.
    return null;
  }

  @override
  void processNonFirstToken(
      dynamic context, Uri sourceUri, String token, dynamic loadable) {
    // TODO: if loadable has a localScopeName, drop into that scope first.
    super.processNonFirstToken(context, sourceUri, token, loadable);
  }
}
