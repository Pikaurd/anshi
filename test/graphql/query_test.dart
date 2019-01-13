import 'package:graphql_schema/graphql_schema.dart';
import 'package:anshi/src/graphql/graphql.dart';
import 'package:test/test.dart';

void main() {
  group('Query test', () {
    final todoType = objectType('todo', fields: [
      field(
        'text',
        graphQLString,
        resolve: (obj, args) => obj.text,
      ),
      field(
        'completed',
        graphQLBoolean,
        resolve: (obj, args) => obj.completed,
      ),
    ]);

    final schema = graphQLSchema(
      queryType: objectType('api', fields: [
        field(
          'todos',
          listOf(todoType),
          resolve: (_, __) => [
                new Todo(
                  text: 'Clean your room!',
                  completed: false,
                )
              ],
        ),
      ]),
    );

    final graphql = new GraphQL(schema);

    setUp(() {
    });

    test('single element test', () async {
      var result = await graphql.parseAndExecute('query X { todos { text, completed } }');

      print(result);
      expect(result, {
        'todos': [
          {'text': 'Clean your room!', 'completed': false}
        ]
      });
    });

    test('mismatch query', () async {
      expect(
        graphql.parseAndExecute('query X { todos { xx } }'), 
        throwsA(const TypeMatcher<GraphQLException>())
      );
    });

  });

}

class Todo {
  final String text;
  final bool completed;

  Todo({this.text, this.completed});
}