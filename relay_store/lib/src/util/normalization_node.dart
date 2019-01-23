import 'dart_relay_node.dart';

class NormalizationOperation extends DartRelayNode {
  NormalizationOperation() : super(#operation, ['kind', 'name', 'argumentDefinitions', 'selections']);
}

abstract class NormalizationHandle extends DartRelayNode {
  NormalizationHandle(Symbol kind, List<String> keys) : super(kind, keys);

  @override
  bool selfCheck() {
    assert(this.kind == #linkedHandle || this.kind == #scalarHandle);
    return super.selfCheck();
  }
}

class NormalizationLinkedHandle extends DartRelayNode {
  NormalizationLinkedHandle() : super(#linkedHandle, [
    'kind',
    'alias',
    'name',
    'args',
    'handle',
    'key',
    'filters',
  ]);
}

class NormalizationScalarHandle extends DartRelayNode {
  NormalizationScalarHandle() : super(#scalarHandle, [
    'kind',
    'alias',
    'name',
    'args',
    'handle',
    'key',
    'filters',
  ]);
}




