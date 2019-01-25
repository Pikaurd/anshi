import 'package:quiver/core.dart';

import 'package:graphql_parser/graphql_parser.dart';
import 'package:graphql_schema/graphql_schema.dart';
import 'package:relay_store/src/util/normalization_node.dart';

void main() {
  final a = Optional.absent();
  final b = Optional<String>.fromNullable(null);
  final c = Optional<String>.of('haha');

  print(a);
}

void foo() {
  print('hello world from relay_store example');
  const g0 = '''
  query BigQuery {
    getUser(id: 1) {
      id
      ...UserFragment
    }
  }
  fragment UserFragment on User { name }
  ''';
  const g1 = 'fragment UserFragment on User { name }';
  final tokens = scan(g0);
  final parser = Parser(tokens);
  final doc = parser.parseDocument();
  print('doc: $doc');
  print(doc.definitions);

}
