import 'package:test/test.dart';
import 'package:anshi/src/persistent/persistent.dart';
import '../common.dart';


void main() {
  group('Model test', () {
    final yifan = User('1', 'yifan', []);
    final davee = User('2', 'davee', [yifan]);

    test('xx', () {
      final operation = Operation(OperationMethod.modify, [Field(FieldType.scalar, 'name')]);
      davee.update(operation);
    });

    test('yy', () async {
      var result = await graphql.parseAndExecute('query X { users { name } }');
      print(result);
    });

  });
}
