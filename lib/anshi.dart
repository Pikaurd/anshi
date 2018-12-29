library anshi;

import 'dart:async';
import 'package:graphql_parser/graphql_parser.dart';

import 'package:anshi/store.dart';

/// 通过[Anshi]访问整体功能
abstract class Anshi {

  /// 通过[graphql]获得所需数据
  Stream<dynamic> fetchQuery(String graphql);

  /// 提交指定的[graphql]修改内容, 修改会影响其他[fetchQuery]获取到的数据
  Future<dynamic> commitMutation(String graphql);

}

class AnshiImplementation implements Anshi {

  RecordStore _store;

  Anshi() {
    _store = Map();
  }

  Stream<dynamic> fetchQuery(String graphql) {
    _store['a'];
    return null;
  }

  Future<dynamic> commitMutation(String graphql) {
    return null;
  }

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

    // print(projectField.arguments.first.name); // name
    // print(projectField.arguments.first.valueOrVariable.value.value); // GraphQL

    // var taglineField = projectField.selectionSet.selections.first.field;
    // print(taglineField.fieldName.name); // tagline
  }
}
