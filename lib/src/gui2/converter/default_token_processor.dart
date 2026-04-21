// Translation of pcgen.gui2.converter.DefaultTokenProcessor

import 'event/token_process_event.dart';
import 'event/token_processor.dart';

/// The default [TokenProcessor] used when no specialist plugin handles a token.
/// Delegates to the load context to parse and re-unparse the token, producing
/// the canonical representation in the output buffer.
class DefaultTokenProcessor implements TokenProcessor {
  @override
  String? process(TokenProcessEvent tpe) {
    final context = tpe.getContext();
    final obj = tpe.getPrimary();

    final bool processed =
        context.processToken(obj, tpe.getKey(), tpe.getValue());
    if (processed) {
      context.commit();
    } else {
      context.rollback();
      context.replayParsedMessages();
    }
    context.clearParseMessages();

    final List<String>? output =
        (context.unparse(obj) as Iterable?)?.cast<String>().toList();
    if (output == null || output.isEmpty) {
      return 'Unable to unparse: ${tpe.getKey()}:${tpe.getValue()}';
    }

    bool needTab = false;
    for (final s in output) {
      if (needTab) {
        tpe.appendChar('\t');
      }
      needTab = true;
      tpe.appendString(s);
    }
    tpe.consume();
    return null;
  }
}
