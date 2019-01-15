import 'package:graphql_schema/graphql_schema.dart';
import 'package:anshi/src/graphql/graphql.dart';
import 'package:test/test.dart';

void main() {
  group('Mutation test', () {
    var aGlobalCounter = Counter(0);

    final schema = graphQLSchema(
      queryType: objectType('Query', fields: [
        field('counter', Counter.type, resolve: (_, __) => aGlobalCounter),
      ]),
      mutationType: objectType('Mutation', fields: [
        field('addCount', Counter.type, resolve: (obj, args) {
          print('obj: $obj \t args: $args');
          aGlobalCounter.count += 1;
          return aGlobalCounter;
        }),
      ]),
    );
    final graphql = GraphQL(schema);

    test('mutation test', () async {
      var read0 = await graphql.parseAndExecute('query X { counter { count } }');
      expect(read0, {'counter': {'count': 0}});

      var write0 = await graphql.parseAndExecute('mutation X { addCount }');
      print('write0: $write0');
      expect(aGlobalCounter.count, 1);

      var read1 = await graphql.parseAndExecute('query X { counter { count } }');
      expect(read1, {'counter': {'count': 1}});
    });
  });
}

// Model definition

class Counter {
  int count;
  Counter(int count): this.count = count;

  static GraphQLObjectType get type => objectType('counter', fields: [
    field('count', graphQLInt, resolve: (obj, _) => obj.count),
  ]);
}
