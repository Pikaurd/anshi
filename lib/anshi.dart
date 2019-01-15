library anshi;

import 'package:graphql_schema/graphql_schema.dart';

export 'src/persistent/persistent.dart';

/// 通过[Anshi]访问整体功能
abstract class AnshiBase {

  /// 获取可响应的Schema
  GraphQLSchema get schema;

}

/// 参考实现
class Anshi implements AnshiBase {

  @override
  // TODO: implement schema
  GraphQLSchema get schema => null;

}

