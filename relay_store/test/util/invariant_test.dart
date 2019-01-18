import 'package:test/test.dart';

import 'package:relay_store/src/util/invariant.dart';

void main() {
  test('null value', () {
    expect(() => invariant(null, 'null value'), throwsA(equals('null value')));
  });
  test('normal value', () {
    invariant(1, 'no throw');
    invariant(true, 'no throw');
  });
  test('false value', () {
    expect(() => invariant(false, 'false value'), throwsA(equals('false value')));
  });
}
