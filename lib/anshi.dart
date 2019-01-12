library anshi;

import 'dart:async';
import 'package:graphql_parser/graphql_parser.dart';
import 'package:graphql_schema/graphql_schema.dart';

import 'package:anshi/src/store/store.dart';

/// 通过[Anshi]访问整体功能
abstract class AnshiBase {

  /// 获取可响应的Schema
  GraphQLSchema get schema;

}

/// 参考实现
class Anshi implements AnshiBase {

  void parseGraphQL(String graphql) {
    final tokens = scan(graphql);
    final parser = Parser(tokens);
    if (parser.errors.isNotEmpty) {
        print('got error');
    }

    var doc = parser.parseDocument();
    final operation = doc.definitions.first as OperationDefinitionContext;
    final projectFields = operation.selectionSet.selections;//.first.field;
    print(projectFields.map((e) => e.field.arguments.map((a) => a.name)));

  }

  @override
  // TODO: implement schema
  GraphQLSchema get schema => null;

}
