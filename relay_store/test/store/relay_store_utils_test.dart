import 'package:test/test.dart';

import 'package:relay_store/src/store/relay_store_utils.dart' as RelayStoreUtils;
import 'package:relay_store/src/store/relay_store_types.dart';
import 'package:relay_store/src/util/graphql_compiler.dart';
import '../test_common.dart';

void main() {
  group('getStorangeKey', () {
    test('uses the field name when there are no arguments', () {
      const text = 'fragment UserFragment on User { name }';
      final userFragment = generateAndCompile(text, schema, allTypes)['UserFragment'];
      final field = userFragment['selections'][0];
      final actual = RelayStoreUtils.getStorageKey(field, Variables());
      expect(actual, 'name');
    });

    test('embed literal argument values', () {
      const text = '''
        fragment UserFragment on User {
          profilePicture(size: 128) { uri }
        }
      ''';
      final field = generateAndCompile(text, schema, allTypes)['UserFragment']['selections'].first;
      final actual = RelayStoreUtils.getStorageKey(field, Variables());
      expect(actual, 'profilePicture(size:128)');
    });
 
  });
}
