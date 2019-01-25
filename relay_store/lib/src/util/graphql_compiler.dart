import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';
import 'package:graphql_parser/graphql_parser.dart';
import 'package:graphql_schema/graphql_schema.dart';

import '../store/relay_store_types.dart';
import './invariant.dart';

GeneratedNode generateAndCompile(String text, GraphQLSchema schema, List<GraphQLObjectType> allTypes) {
  final tokens = scan(text);
  final parser = Parser(tokens);
  final doc = parser.parseDocument();

  final generator = SelectorGenerator(doc, schema, allTypes);
  final result = generator.generate();
  
  return result;
}

class SelectorGenerator {
  GraphQLSchema _schema;
  DocumentContext _doc;
  Map<String, GraphQLObjectType> _allTypes;
  GeneratedNode _result;

  SelectorGenerator(this._doc, this._schema, List<GraphQLObjectType> allTypes) {
    this._result = GeneratedNode();

    this._allTypes = allTypes.fold({}, (acc, e) {
      acc[e.name] = e;
      return acc;
    });
  }

  GeneratedNode generate() {
    this._doc.definitions.forEach((definition) {
      if (definition is OperationDefinitionContext) {
        // query | mutation | subscription
        // FIXME: only query implemented
        this._result[definition.name] = this._operationHandle(definition);
      } else if (definition is FragmentDefinitionContext) {
        final typeName = definition.name;
        this._result[typeName] = this._fragmentHandle(definition);
      } else {
        throw 'unknow context from $definition';
      }
    });
    return _result;
  }

  GeneratedNode _operationHandle(OperationDefinitionContext context) {
    // TODO: implement mutation and subscription
    var node = GeneratedNode();
    node['kind'] = 'Request';
    // >>> construct fragment for operation
    var fragmentNode = GeneratedNode();
    final type = context.TYPE;
    if (type.type == TokenType.QUERY) {
      fragmentNode['type'] = 'Query';
      fragmentNode['kind'] = 'Fragment';
      fragmentNode['name'] = context.name;
      fragmentNode['argumentDefinitions'] = []; // TODO: not handle
      final nextTypeName = this._getTypeFromQueryFieldFromSelections(context.selectionSet.selections);
      fragmentNode['selections'] = this._selectionsHandle(context.selectionSet, nextTypeName);
    } else if (type.type == TokenType.MUTATION) {
      throw 'NOT implement type: $type';
    } else {
      throw 'NOT implement type: $type';
    }
    node['fragment'] =  fragmentNode;
    // node['operation'] = ;
    // node['params'] = ;
    return node;
  }

  GeneratedNode _fragmentHandle(FragmentDefinitionContext context) {
    var node = GeneratedNode();
    final typeName = context.typeCondition.typeName.name;
    final objectType = this._getGraphqlObjectType(typeName);
    node['kind'] = 'Fragment';
    node['name'] = context.name;
    node['type'] = typeName;
    node['argumentDefinitions'] = []; // TODO: hard write
    node['selections'] = this._selectionsHandle(context.selectionSet, objectType);
    return node;
  }

  List<GeneratedNode> _selectionsHandle(SelectionSetContext selectionSet, GraphQLType parentType) {
    final iter = selectionSet.selections.map((selectionContext) {
      if (parentType is GraphQLListType) {
        return this._fieldHandle(selectionContext.field, parentType, parentType);
      } else if (parentType is GraphQLObjectType) {
        GraphQLType fieldType;
        try {
          fieldType = parentType.fields.firstWhere((e) => e.name == selectionContext.field.fieldName.name).type;
        } on StateError catch(_) {
          fieldType = parentType;
        }
        return this._fieldHandle(selectionContext.field, fieldType, parentType);
      } else {
        throw 'should NOT expand';
      }
    } );
    return iter.toList();
  }

  GeneratedNode _fieldHandle(FieldContext field, GraphQLType fieldType, GraphQLType parentType) {
    final nodeName = field.fieldName.name;
    var node = GeneratedNode();
    node['name'] = nodeName;
    node['args'] = this.getArgumentValues(field, parentType);
    node['storageKey'] = getStorageKey(field);

    if (fieldType is GraphQLListType) {
      node['kind'] = 'LinkedField';
      node['plural'] = true;
      node['selections'] = this._selectionsHandle(field.selectionSet, fieldType.ofType);
    } else if (fieldType is GraphQLObjectType) {
      node['kind'] = 'LinkedField';
      node['plural'] = false;
      node['selections'] = this._selectionsHandle(field.selectionSet, fieldType);
    } else if (fieldType is GraphQLScalarType) {
      node['kind'] = 'ScalarField';
    }
    else {
      throw 'not implemented GraphQLType: $fieldType';
    }

    return node;
  }

  GeneratedNode _operationHandleNode() {

  }

  // helper methods

  List<GeneratedNode> getArgumentValues(FieldContext field, GraphQLType parentType) {
    final arguments = field.arguments;
    if (arguments.length == 0) return null;
    print('arguments: $arguments');

    final inputFiledTypeFromParent = parentType is GraphQLObjectType ? _getInputFieldsFromType(field, parentType) : [];
    final inputsType = inputFiledTypeFromParent.length > 0 ? inputFiledTypeFromParent : _getTypeFromQueryField(field, this._schema);
    var nodes = List<GeneratedNode>();
    nodes = arguments.map((e) {
      GraphQLFieldInput fieldInput = inputsType.firstWhere((g) => e.name == g.name);
      GeneratedNode node = GeneratedNode();
      node['kind'] = 'Literal';  // TODO: hard code
      node['name'] = e.name;
      node['value'] = e.valueOrVariable.value.value;
      node['type'] = fieldInput.type.name;
      return node;
    }).toList();

    return nodes;
  }

  GraphQLObjectType _getGraphqlObjectType(String typeName) {
    final object = this._allTypes[typeName];
    invariant(field != null, 'Object $typeName does not have exist in ${this._allTypes.keys}');
    return object;
  }

  GraphQLType _getTypeFromQueryFieldFromSelections(List<SelectionContext> selections) {
    final fieldName = selections.first.field.fieldName.name;
    invariant(fieldName != null, 'SelectorGenerator: fetch fieldName failed in ${selections}');
    final objectField = this._schema.queryType.fields.firstWhere((field) => field.name == fieldName);
    return objectField.type;
  }

}


String getStorageKey(FieldContext field) {
  if (field == null) return null;
  if (field.arguments.length == 0) return null;
  print('getStorageKey: $field');

  final x = field.arguments.map((e) => '${e.name}:${e.valueOrVariable.value.value}').toList();
  final arguments = x.join(',');
  return '${field.fieldName.name}($arguments)';
}



List<GraphQLFieldInput> _getTypeFromQueryField(FieldContext field, GraphQLSchema schema) {
  final fieldName = field.fieldName.name;
  final objectField = schema.queryType.fields.firstWhere((field) => field.name == fieldName);
  return objectField.inputs;
}

List<GraphQLFieldInput> _getInputFieldsFromType(FieldContext field, GraphQLObjectType type) {
  for (final item in type.fields) {
    if (item.name == field.fieldName.name) {
      return item.inputs;
    }
  }
  return [];
}
