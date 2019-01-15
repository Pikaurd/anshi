import 'package:graphql_schema/graphql_schema.dart';

import 'package:anshi/src/graphql/graphql.dart';


abstract class Store {

  GraphQLSchema get schema;

  GraphQL get client;
}

class NaiveStore implements Store {

  GraphQL _client;
  final GraphQLSchema _schema;

  NaiveStore(this._schema) {
    this._client = GraphQL(schema);
  }

  @override
  GraphQL get client => _client;

  @override
  GraphQLSchema get schema => _schema;

}
