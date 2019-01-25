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

  group('setLinkedRecordID()', (){
    test('sets a link', (){
      final record = Record({RelayUtilKeys.idKey: '4'});
      RelayRecord.setLinkedRecordID(record, 'pet', 'beast');
      expect(RelayRecord.getLinkedRecordID(record, 'pet').value, 'beast');
    });
  });

  group('setLinkedRecordIDs()', (){
    test('sets an array of links', () {
      final record = Record({RelayUtilKeys.idKey: '4'});
      final storageKey = 'friends{"first":10}';
      RelayRecord.setLinkedRecordIDs(record, storageKey, ['beast', 'greg', null]);
      expect(RelayRecord.getLinkedRecordIDs(record, storageKey).value, ['beast', 'greg', null]);
    });
  });

  group('getValue()', (){
    Record record;
    setUp(() {
      record = Record({
        RelayUtilKeys.idKey: 4,
        'name': 'Mark',
        'blockbusterMembership': null,
        'hometown': { RelayUtilKeys.refKey: 'mpk'},
        'friends{"first":10}': { RelayUtilKeys.refsKey: ['beast', 'greg']},
        'favoriteColors': ['red', 'green', 'blue'],
        'other': Record({ 'customScalar': true }),
      });
    });

    test('returns a scalar value', (){
      expect(RelayRecord.getValue(record, 'name'), 'Mark');
    });

    test('returns a (list) scalar value', (){
      expect(RelayRecord.getValue(record, 'favoriteColors'), ['red', 'green', 'blue']);
    });

    test('returns a (custom object) scalar value', (){
      expect(RelayRecord.getValue(record, 'other'), {'customScalar': true});
    });

    test('returns null when the field is non-existent', () {
      expect(RelayRecord.getValue(record, 'blockbusterMembership'), null);
    });

    test('returns null when the field is unknown', () {
      expect(RelayRecord.getValue(record, 'horoscope'), null);
    });

    test('throws on encountering a linked record', () {
      expect(() => RelayRecord.getValue(record, 'hometown'), 
        throwsA('getValue(): Expected a scalar (non-link) value for `4.hometown` but found a linked record'));
    });

    test('throws on encountering a plural linked record', () {
      expect(() => RelayRecord.getValue(record, 'friends{"first":10}'), 
        throwsA('getValue(): Expected a scalar (non-link) value for `4.friends{"first":10}` but found plural linked records'));
    });

  });

  // group('freeze()', () {
  //   test('prevents modification of record', () {
  //     final record = RelayRecord.create('4', 'User');
  //     RelayRecord.freeze(record);
  //   });
  // });

  group('update()', () {
    test('returns the first record if there are no changes', () {
      final prev = RelayRecord.create('4', 'User');
      final next = RelayRecord.clone(prev);
      RelayRecord.setValue(prev, 'name', 'Zuck');
      final updated = RelayRecord.update(prev, next);
      expect(identical(updated, prev), true);
      expect(identical(updated, next), false);
      expect(updated, equals({ RelayUtilKeys.idKey: '4', RelayUtilKeys.typenameKey: 'User', 'name': 'Zuck' }));
    });

    test('returns a new record if there are changes', () {
      final prev = RelayRecord.create('4', 'User');
      final next = RelayRecord.clone(prev);
      RelayRecord.setValue(next, 'name', 'Zuck');
      final updated = RelayRecord.update(prev, next);
      expect(identical(updated, prev), false);
      expect(identical(updated, next), false);
      expect(updated, equals({ RelayUtilKeys.idKey: '4', RelayUtilKeys.typenameKey: 'User', 'name': 'Zuck' }));
    });

    test('returns a new record with unpublished fields removed', () {
      final prev = RelayRecord.create('4', 'User');
      RelayRecord.setValue(prev, 'name', 'Zuck');
      final next = RelayRecord.clone(prev);
      RelayRecord.setValue(next, 'name', RelayUtilKeys.unpublishFieldSentinel);
      final updated = RelayRecord.update(prev, next);
      expect(identical(updated, prev), false);
      expect(identical(updated, next), false);
      expect(updated, equals({ RelayUtilKeys.idKey: '4', RelayUtilKeys.typenameKey: 'User' }));
    });

  });

  group('merge()', () {
    test('returns a new record even if there are no changes', () {
      final prev = RelayRecord.create('4', 'User');
      RelayRecord.setValue(prev, 'name', 'Zuck');
      final next = RelayRecord.clone(prev);
      final updated = RelayRecord.merge(prev, next);
      expect(identical(updated, prev), false);
      expect(identical(updated, next), false);
      expect(updated, equals({
        RelayUtilKeys.idKey: '4', RelayUtilKeys.typenameKey: 'User', 'name': 'Zuck'
      }));
    });

    test('returns a new record if there are changes', () {
      final prev = RelayRecord.create('4', 'User');
      final next = RelayRecord.clone(prev);
      RelayRecord.setValue(next, 'name', 'Zuck');
      final updated = RelayRecord.merge(prev, next);
      expect(identical(updated, prev), false);
      expect(identical(updated, next), false);
      expect(updated, equals({
        RelayUtilKeys.idKey: '4', RelayUtilKeys.typenameKey: 'User', 'name': 'Zuck'
      }));
    });

    test('includes unpublished field sentinels', () {
      final prev = RelayRecord.create('4', 'User');
      RelayRecord.setValue(prev, 'name', 'Zuck');
      final next = RelayRecord.clone(prev);
      RelayRecord.setValue(next, 'name', RelayUtilKeys.unpublishFieldSentinel);
      final updated = RelayRecord.merge(prev, next);
      expect(identical(updated, prev), false);
      expect(identical(updated, next), false);
      expect(updated, equals({
        RelayUtilKeys.idKey: '4', RelayUtilKeys.typenameKey: 'User', 'name': RelayUtilKeys.unpublishFieldSentinel
      }));
    });
  });

}