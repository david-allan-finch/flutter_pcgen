// Translation of pcgen.gui2.converter.event.TokenProcessorPlugin

import 'token_processor.dart';

/// Extension of [TokenProcessor] that additionally declares which CDOMObject
/// class and token name it handles.  Implementations are discovered and
/// registered via [TokenConverter.addToTokenMap].
abstract class TokenProcessorPlugin extends TokenProcessor {
  /// Returns the [Type] of the CDOMObject subclass this plugin handles.
  Type getProcessedClass();

  /// Returns the token key string (e.g. "ABILITY") this plugin handles.
  String getProcessedToken();
}
