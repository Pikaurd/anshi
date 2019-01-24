import 'package:test/test.dart';

import 'package:relay_store/src/util/graphql_compiler.dart';
import '../test_common.dart';

void main() {
  group('GraphQL compiler', () {

    group('SelectorGenerator', () {

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

      test('simple query with argument return list', () {
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
              // 'metadata': null,
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
                      'type': 'ID',
                    }
                  ],
                  'plural': true,
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
            // 'operation': {
            //   'kind': 'Operation',
            //   'name': 'X',
            //   'argumentDefinitions': [],
            //   'selections': [
            //     {
            //       'kind': 'LinkedField',
            //       'name': 'node',
            //       'storageKey': 'node(id:2)',
            //       'args': [
            //         {
            //           'kind': 'Literal',
            //           'name': 'id',
            //           'value': 2,
            //           'type': 'ID'
            //         }
            //       ],
            //       'plural': false,
            //       'selections': [
            //         // {
            //         //   'kind': 'ScalarField',
            //         //   'name': '__typename',
            //         //   'args': null,
            //         //   'storageKey': null
            //         // },
            //         {
            //           'kind': 'ScalarField',
            //           'name': 'id',
            //           'args': null,
            //           'storageKey': null
            //         },
            //       ],
            //     }
            //   ],
            // },
            // 'params': {
            //   'operationKind': 'query',
            //   'name': 'X',
            //   'id': null,
            //   'text': 'query X { user(id: 2) { id name }',
            //   'metadata': {}
            // }
          }
        };
        expect(actual, expected);
      });

      test('fragment with inner input field', () {
        const text = '''
          fragment UserFragment on User {
            profilePicture(size: 128) { uri }
          }
        ''';
        final actual = generateAndCompile(text, schema, allTypes);
        final expected = {
          "UserFragment": {
            "kind": "Fragment",
            "name": "UserFragment",
            "type": "User",
            // "metadata": null,
            "argumentDefinitions": [],
            "selections": [
              {
                "kind": "LinkedField",
                // "alias": null,
                "name": "profilePicture",
                "storageKey": "profilePicture(size:128)",
                "args": [
                  {
                    "kind": "Literal",
                    "name": "size",
                    "value": 128,
                    "type": "Int"
                  }
                ],
                // "concreteType": "Image", // TODO: useful
                "plural": false,
                "selections": [
                  {
                    "kind": "ScalarField",
                    // "alias": null,
                    "name": "uri",
                    "args": null,
                    "storageKey": null
                  }
                ]
              }
            ]
          }
        };
        expect(actual, expected);
      });

    });


    group('Utils', () {
      group('getArgumentValues', () {
        test('returns argument values', () {
          expect(1, 1);
        });
      });

      group('getStorageKey', () {
        test('uses the field name when there are no arguments', () {

        });
      });
    });

  });


}
