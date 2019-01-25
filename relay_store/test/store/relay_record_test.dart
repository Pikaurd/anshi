import 'package:quiver/core.dart';
import 'package:test/test.dart';

import 'package:relay_store/src/store/relay_store_types.dart';
import 'package:relay_store/src/store/relay_record.dart' as RelayRecord;
import 'package:relay_store/src/store/relay_store_utils.dart';

void main() {
  group('clone', () {
    test('returns a shallow copy of the record', () {
      final record = Record({
        RelayUtilKeys.idKey: '4',
        'name': 'Mark',
        'pet': {
          RelayUtilKeys.refKey: 'beast',
        },
      });
      final clone = RelayRecord.clone(record);
      expect(clone, record);
      expect(identical(record, clone), false);
      expect(clone['pet'], record['pet']);
    });
  });

  group('copyFields', () {
    test('copies fields', (){
      final sink = Record({RelayUtilKeys.idKey: '4', RelayUtilKeys.typenameKey: 'User'});
      final source = Record({
        RelayUtilKeys.idKey: '__4',
        RelayUtilKeys.typenameKey: '__User',
        'name': 'Zuck',
        'pet': {RelayUtilKeys.refKey: 'beast'},
        'pets': {RelayUtilKeys.refsKey: ['beast']}
      });
      RelayRecord.copyFields(source, sink);
      expect(sink, {
        RelayUtilKeys.idKey: '4',
        RelayUtilKeys.typenameKey: 'User',
        'name': 'Zuck',
        'pet': {RelayUtilKeys.refKey: 'beast'},
        'pets': {RelayUtilKeys.refsKey: ['beast']}
      });
    });
  });

  group('getLinkedRecordIDs', (){
    final record = Record({
      RelayUtilKeys.idKey: 4,
      'name': 'Mark',
      'enemies': null,
      'hometown': { RelayUtilKeys.refKey: 'mpk' },
      'friends{"first":10}': { RelayUtilKeys.refsKey: ['beast', 'greg', null ]}
    });

    test('returns null when the link is unknown', () {
      expect(RelayRecord.getLinkedRecordID(record, 'colors'), Optional.absent());
    });

    test('returns null when the link is non-existent', () {
      expect(RelayRecord.getLinkedRecordID(record, 'enemies'), Optional.absent());
    });

    test('returns the linked record IDs when they exist', () {
      final actual = RelayRecord.getLinkedRecordIDs(record, 'friends{"first":10}');
      expect(
        actual,
        Optional<List<String>>.of(['beast', 'greg', null])
      );
    });

    test('throws if the field is actually a scalar', () {
      expect(
        () => RelayRecord.getLinkedRecordIDs(record, 'name'), 
        throwsA('getLinkedRecordIDs expect `4.name` to contain an array of linked IDs, got `Mark`'));
    });

    test('throws if the field is singluar link', () {
      expect(
        () => RelayRecord.getLinkedRecordIDs(record, 'hometown'), 
        throwsA('getLinkedRecordIDs expect `4.hometown` to contain an array of linked IDs, got `{__ref: mpk}`'));
    });

  });
}