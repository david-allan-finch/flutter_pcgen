// Translation of pcgen.output.factory.ChannelFactory

import '../base/model_factory.dart';

/// A ModelFactory that produces output from a channel variable (CControl).
class ChannelFactory implements ModelFactory {
  final dynamic _control;

  ChannelFactory(this._control);

  @override
  dynamic generate(String charId) {
    // TODO: resolve variable from SolverManager for charId and _control
    return null;
  }
}
