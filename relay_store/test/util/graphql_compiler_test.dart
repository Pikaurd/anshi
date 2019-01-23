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
        field('node', listOf(userSchema), inputs: [GraphQLFieldInput('id', graphQLId)]),
      ]),
    );
    final allTypes = [userSchema, addressSchema];

    test('simple fragment with inner object', () {
      final actual = generateAndCompile('fragment UF on User { address { text } }', schema, allTypes);
      final expected = {
        'UF': {
          'kind': 'Fragment',
          'name': 'UF',
          'type': 'User',
          'argumentDefinitions': [],
          'selections': [
            {
              'kind': 'LinkedField',
              'name': 'address',
              'args': null,
              'storageKey': null,
              'plural': false,
              'selections': [
                {
                  'kind': 'ScalarField',
                  'name': 'text',
                  'args': null,
                  'storageKey': null,
                }
              ]
            }
          ],
        },
      };
      expect(actual, expected);
    });

    test('simple fragment with type', () {
      final actual = generateAndCompile('fragment UF on User { name }', schema, allTypes);
      final expected = {
        'UF': {
          'kind': 'Fragment',
          'name': 'UF',
          'type': 'User',
          'argumentDefinitions': [],
          'selections': [
            {
              'kind': 'ScalarField',
              'name': 'name',
              'args': null,
              'storageKey': null,
            }
          ],
        },
      };
      expect(actual, expected);
    });

    test('simple query with argument', () {
      final text = '''
      query X { node(id: 2) { id } }
      ''';
      final actual = generateAndCompile(text, schema, allTypes);
      final expected = {
        'X': {
          'kind': 'Request',
          'fragment': {
            'kind': 'Fragment',
            'name': 'X',
            'type': 'Query',
            'metadata': null,
            'argumentDefinitions': [],
            'selections': [
              {
                'kind': 'LinkedField',
                'name': 'node',
                'sotrangeKey': 'node(id:2)',
                'args': [
                  {
                    'kind': 'Literal',
                    'name': 'id',
                    'value': 2,
                    'type': 'ID',
                  }
                ],
                'plural': false,
                'selections': [
                  {
                    'kind': 'ScalarField',
                    'name': 'id',
                    'args': null,
                    'storageKey': null,
                  },
                ],
              }
            ],
          },
          'operation': {
            'kind': 'Operation',
            'name': 'X',
            'argumentDefinitions': [],
            'selections': [
              {
                'kind': 'LinkedField',
                'name': 'node',
                'storageKey': 'node(id:2)',
                'args': [
                  {
                    'kind': 'Literal',
                    'name': 'id',
                    'value': 2,
                    'type': 'ID'
                  }
                ],
                'plural': false,
                'selections': [
                  // {
                  //   'kind': 'ScalarField',
                  //   'name': '__typename',
                  //   'args': null,
                  //   'storageKey': null
                  // },
                  {
                    'kind': 'ScalarField',
                    'name': 'id',
                    'args': null,
                    'storageKey': null
                  },
                ],
              }
            ],
          },
          'params': {
            'operationKind': 'query',
            'name': 'X',
            'id': null,
            'text': 'query X { user(id: 2) { id name }',
            'metadata': {}
          }
        }
      };
      expect(actual, expected);
    });

  });
}
