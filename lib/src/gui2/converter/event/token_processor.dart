// Translation of pcgen.gui2.converter.event.TokenProcessor

import 'token_process_event.dart';

/// Functional interface for processing a single LST token during conversion.
/// Returns an error message string, or null on success.
abstract class TokenProcessor {
  String? process(TokenProcessEvent tpe);
}
