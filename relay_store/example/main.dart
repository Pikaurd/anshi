import 'package:graphql_parser/graphql_parser.dart';
import 'package:graphql_schema/graphql_schema.dart';
import 'package:relay_store/src/util/normalization_node.dart';

void main() {
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
  // foo();
}

void foo() {
  var a = NormalizationOperation();
  a['name'] = 'haha';
  a['argumentDefinitions'] = ['haha'];
  a['selections'] = [];
  a.selfCheck();
  print(a);
}
