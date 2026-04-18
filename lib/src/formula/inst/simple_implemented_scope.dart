import '../base/implemented_scope.dart';

class SimpleImplementedScope implements ImplementedScope {
  final String _name;
  final bool _global;
  final List<ImplementedScope> _drawsFrom;

  SimpleImplementedScope(this._name, {bool global = false, List<ImplementedScope>? drawsFrom})
      : _global = global,
        _drawsFrom = drawsFrom ?? [];

  @override
  bool isGlobal() => _global;

  @override
  String getName() => _name;

  @override
  List<ImplementedScope> drawsFrom() => List.unmodifiable(_drawsFrom);

  @override
  String toString() => 'SimpleImplementedScope($_name)';
}
