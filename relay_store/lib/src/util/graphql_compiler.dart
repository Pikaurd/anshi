import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';
import 'package:graphql_parser/graphql_parser.dart';
import 'package:graphql_schema/graphql_schema.dart';

import './dart_relay_node.dart';
import './normalization_node.dart';
import './reader_node.dart';
import './invariant.dart';

class ConcreteRequest extends DartRelayNode {

  @override
  void selfCheck() {
    final message = '\t GOT $data';
    invariant(data['kind'] == #request, 'kind should be `request` $message');
    invariant(
      data['operationKind'] is String && (
        data['operationKind'] == 'mutation' || 
        data['operationKind'] == 'query' || 
        data['operationKind'] == 'subscription'
      ), 
      'operationKind must in "mutation | query | subscription" $message'
    );
    invariant(data['name'] is String, 'name should be String. $message');
    invariant(data.containsKey('id'), 'key `id` not present');
    if (data['id'] != null) {
      invariant(data['id'] is String, 'id should be String. $message');
    }
    if (data['text'] != null) {
      invariant(data['text'] is String, 'text should be String. $message');
    }
    invariant(data.containsKey('metadata'), 'key `metadata` not present $message');
    invariant(data.containsKey('fragment'), 'key `fragment` not present $message');
    invariant(data.containsKey('operation'), 'key `operation` not present $message');
  }

  @override
  bool validate(String key, value) {
    // TODO: implement validate
    return null;
  }
}

enum ConcreteRequestOperationKind {
  mutation, query, subscription
}

/*
export type GeneratedNode =
  | ConcreteRequest
  | ReaderFragment
  | NormalizationSplitOperation;
*/
Map<String, dynamic> generateAndCompile(String text, GraphQLSchema schema) {

  return {};
}
