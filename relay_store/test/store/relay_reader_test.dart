import 'package:test/test.dart';

import 'package:relay_store/src/store/relay_store_types.dart';
import 'package:relay_store/src/store/relay_response_normalizer.dart';
import 'package:relay_store/src/util/graphql_compiler.dart';
import 'package:relay_store/src/store/relay_in_memory_record_source.dart';
import 'package:relay_store/src/store/relay_store_types.dart';
import 'package:relay_store/src/store/relay_record.dart';
import 'package:relay_store/src/store/relay_store_utils.dart';
import 'package:relay_store/src/store/relay_reader.dart';
import 'package:relay_store/src/util/dart_relay_node.dart';
import 'package:relay_store/src/store/relay_in_memory_record_source.dart';


import '../test_common.dart';

void main() {
  group('RelayReader', () {
    MutableRecordSource source;
    final data = {
      '1': Record({
        '__id': '1',
        'id': '1',
        '__typename': 'User',
        'name': 'haha',
        'address': {'__ref': 'client:1:address'},
      }),
      'client:1:address': Record({
        '__id': 'client:1:address',
        '__typename': 'Address',
        'text': 'S1',
      }),
      'client:root': Record({
        '__id': 'client:root',
        '__typename': '__Root',
        'node(id:1)': {'__ref': '1'},
      })
    };

    setUp(() {
      source = RelayInMemoryRecordSource(RecordMap(data));
    });

    test('simple test', () {
      const text = 'query X { node(id: 1) { id name address { text } } } }';
      final x = generateAndCompile(text, schema, allTypes)['X'];
      final selector = _ReaderSelector();
      selector.dataID = 'client:root';
      selector.readerNode = x['fragment'];
      Snapshot snapshot = read(source, selector);
      expect(snapshot.data, equals({
        'node': {
          'id': '1',
          '__typename': 'User',
          'name': 'haha',
          'address': {
            'text': 'S1',
            '__typename': 'Address',
          }
        }
      }));
      expect(snapshot.seenRecords.keys, equals(['client:root']));
    });
  });
}

class _ReaderSelector extends ReaderSelector<RelayObject> {}
