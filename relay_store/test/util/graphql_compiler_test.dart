import 'package:test/test.dart';
import 'package:graphql_schema/graphql_schema.dart';

import 'package:relay_store/src/util/graphql_compiler.dart';

void main() {
  group('GraphQL compiler', () {
    final addressSchema = objectType('Address', fields: [
      field('id', graphQLString),
      field('text', graphQLString),
    ]);
    final userSchema = objectType('User', fields: [
      field('id', graphQLString),
      field('name', graphQLString),
      field('address', addressSchema),
    ]);
    final schema = GraphQLSchema(
      queryType: objectType('query', fields: [
        field('users', listOf(userSchema)),
        field('user', userSchema),
      ]),
    );

    test('ConcreteRequest', () {
      var a = ConcreteRequest();
      a['name'] = 'haha';
      expect(a['name'], 'haha');
    });

    test('simple fragment', () {
      final actual = generateAndCompile('fragment UF on User { name }', schema);
      /*
      { kind: 'Fragment',
      name: 'UserFragment',
      type: 'User',
      metadata: null,
      argumentDefinitions: [],
      selections:
       [ { kind: 'ScalarField',
           alias: null,
           name: 'name',
           args: null,
           storageKey: null } ] }
       */
      final expected = {
        'kind': #fragment,
      };
      expect(actual, expected);
    });

  });
}
