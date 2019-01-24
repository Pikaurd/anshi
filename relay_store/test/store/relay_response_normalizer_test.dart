import 'package:quiver/core.dart';
import 'package:relay_store/src/store/relay_record_state.dart';
import 'package:test/test.dart';
import 'package:graphql_schema/graphql_schema.dart';

import 'package:relay_store/src/store/relay_store_types.dart';
import 'package:relay_store/src/store/relay_response_normalizer.dart';
import 'package:relay_store/src/util/graphql_compiler.dart';
import 'package:relay_store/src/store/relay_in_memory_record_source.dart';
import 'package:relay_store/src/store/relay_store_types.dart' as Types;
import 'package:relay_store/src/util/normalization_node.dart';
import 'package:relay_store/src/util/dart_relay_node.dart';

void main() {
  group('RelayResponseNormalizer', () {
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
        field('nodes', listOf(userSchema), inputs: [GraphQLFieldInput('id', graphQLId)]),
        field('node', listOf(userSchema), inputs: [GraphQLFieldInput('id', graphQLId)]),
      ]),
    );
    final allTypes = [userSchema, addressSchema];

    test('normalize queries', () {
      const text = 'query X { node(id: 2) { id name } }';
      final x = generateAndCompile(text, schema, allTypes)['X'];
      
      final Map<String, dynamic> payload = {
        'node': {
          'id': 1,
          '__typename': 'User',
          'name': 'haha',
        },
      };

      final recordSource = RelayInMemoryRecordSource();
      final record = Types.Record();
      record['__id'] = 'client:root';
      record['__typename'] = '__Root';
      recordSource.set('client:root', record);

      final selector = TSelector();
      selector.dataID = 'client:root';
      selector.node = x['fragment'];

      normalize(recordSource, selector, payload);

      final actual = recordSource.toJSON();
      final expected = {
        '1': {
          '__id': '1',
          'id': '1',
          '__typename': 'User',
          'name': 'haha',
        },
        'client:root': {
          '__id': 'client:root',
          '__typename': '__Root',
          'node(id:2)': {'__ref': '1'},
        }
      };
      expect(actual, expected);
    });
  });
}

class TSelector extends NormalizationSelector<GeneratedNode> { }
