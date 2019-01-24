import 'package:graphql_schema/graphql_schema.dart';


final imageSchema = objectType('Image', fields: [
  field('uri', graphQLString),
  field('width', graphQLInt),
  field('height', graphQLInt),
]);

final addressSchema = objectType('Address', fields: [
  field('id', graphQLString),
  field('text', graphQLString),
]);

final userSchema = objectType('User', fields: [
  field('id', graphQLString),
  field('name', graphQLString),
  field('address', addressSchema),
  field('profilePicture', imageSchema, inputs: [GraphQLFieldInput('size', graphQLInt)]),
]);

final schema = GraphQLSchema(
  queryType: objectType('query', fields: [
    field('users', listOf(userSchema)),
    field('user', userSchema),
    field('node', listOf(userSchema), inputs: [GraphQLFieldInput('id', graphQLId)]),
  ]),
);

final allTypes = [userSchema, addressSchema];
