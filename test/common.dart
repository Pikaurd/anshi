import 'package:graphql_schema/graphql_schema.dart';
import 'package:anshi/src/graphql/graphql.dart';
import 'package:anshi/src/persistent/persistent.dart';

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
  queryType: objectType('query', fields: [
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
    field(
      'users', 
      listOf(User.graphQLType),
      resolve: (obj, args) {
        print('obj: $obj');
        print('args: $args');
        return [User('1', 'yifan', []), User('2', 'Davee', [])];
      }
    ),
  ]),
);

final graphql = new GraphQL(schema);

// model define
class User implements BaseModel {

  String _identifier;
  String name;
  List<User> friends;

  User(String identifier, String name, List<User> friends) {
    this._identifier = identifier;
    this.name = name;
    this.friends = friends;
  }

  @override
  List<Field> fields() {
    return [
      Field(FieldType.scalar, 'identifier'),
      Field(FieldType.scalar, 'name'),
      Field(FieldType.field, 'friends'),
    ];
  }

  @override
  String get identifier => 'User:$_identifier';

  @override
  void notify() {
    // TODO: implement notify
  }

  @override
  FieldType get type => FieldType.field;

  @override
  void update(Operation operation) {
    // TODO: implement update
  }

  static GraphQLObjectType get graphQLType => objectType('User', fields: [
    field('identifier', graphQLString, resolve: (obj, args) => obj.identifier),
    field('name', graphQLString, resolve: (obj, args) => obj.name),
    // field('friends', GraphQLListType(graphQLType), resolve: (obj, args) => []),
  ]);

}

class Todo {
  final String text;
  final bool completed;

  Todo({this.text, this.completed});
}
