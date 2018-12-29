import 'package:test/test.dart';

import 'package:anshi/anshi.dart';

void main() {
  // test('adds one to input values', () {
  //   final calculator = Calculator();
  //   expect(calculator.addOne(2), 3);
  //   expect(calculator.addOne(-7), -6);
  //   expect(calculator.addOne(0), 1);
  //   // expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  // });

  test('Anshi main functions', () {
    final AnshiImplementation a = AnshiImplementation();
    const graphql = 'query A { user { id, name, children { edges { node { id, name } } } } }';
    a.parseGraphQL(graphql);
    expect(1, 1);
  });
}
