import 'package:graphql_parser/graphql_parser.dart';
import 'package:graphql_schema/graphql_schema.dart';

void main() {
  print('hello world from relay_store example');
  const graphQL = '''
  query BigQuery {
    getUser(id: 1) {
      id
      ...UserFragment
    }
  }
  fragment UserFragment on User { name }
  ''';
  final tokens = scan(graphQL);
  final parser = Parser(tokens);
  final doc = parser.parseDocument();
}
