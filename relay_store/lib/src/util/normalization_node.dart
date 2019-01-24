import 'dart_relay_node.dart';
import '../store/relay_store_types.dart';


// ['kind', 'name', 'argumentDefinitions', 'selections']
class NormalizationOperation extends NormalizationBaseNode {
  NormalizationOperation() : super(NormalizationKind.operation);
}

// [ 'kind', 'alias', 'name', 'args', 'handle', 'key', 'filters', ]
class NormalizationLinkedHandle extends NormalizationBaseNode {
  NormalizationLinkedHandle() : super(NormalizationKind.linkedHandle);
}

class NormalizationScalarHandle extends NormalizationBaseNode {
  NormalizationScalarHandle() : super(NormalizationKind.scalarHandle);
}

abstract class NormalizationBaseNode extends RelayObject {
  final String kind;
  NormalizationBaseNode(this.kind) {
    this['kind'] = this.kind;
  }
}

class NormalizationKind {
  NormalizationKind._();

  static const operation = 'Operation';
  static const linkedHandle = 'LinkedHandle';
  static const scalarHandle = 'ScalarHandle';
  static const condition = 'Condition';
  static const rootArgument = 'RootArgument';
  static const inlineFragment = 'InlineFragment';
  static const linkedField = 'LinkedField';
  static const matchField = 'MatchField';
  static const literal = 'Literal';
  static const localArgument = 'LocalArgument';
  static const scalarField = 'ScalarField';
  static const splitOperation = 'SplitOperation';
  static const variable = 'Variable';
}
