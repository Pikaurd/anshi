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
    // var fragmentNode = GeneratedNode();
    // final typeName = context.typeCondition.typeName.name;
    // fragmentNode['kind'] = 'Fragment';
    // fragmentNode['name'] = context.name;
    // fragmentNode['type'] = typeName;
    // fragmentNode['argumentDefinitions'] = [];
    // fragmentNode['selections'] = this._selectionsHandle(context.selectionSet, typeName);
    // <<< 
    // node['fragment'] =  fragmentNode;
    // node['operation'] = ;
    // node['params'] = ;
    return node;
  }

  GeneratedNode _fragmentHandle(FragmentDefinitionContext context) {
    var node = GeneratedNode();
    final typeName = context.typeCondition.typeName.name;
    node['kind'] = 'Fragment';
    node['name'] = context.name;
    node['type'] = typeName;
    node['argumentDefinitions'] = [];
    node['selections'] = this._selectionsHandle(context.selectionSet, typeName);
    return node;
  }

  List<GeneratedNode> _selectionsHandle(SelectionSetContext selectionSet, String onType) {
    final iter = selectionSet.selections.map((selectionContext) {
      // if (selectionContext)
      return this._fieldHandle(selectionContext.field, onType);
    } );
    return iter.toList();
  }

  GeneratedNode _fieldHandle(FieldContext field, String onType) {
    final nodeName = field.fieldName.name;
    var node = GeneratedNode();
    node['name'] = nodeName;
    node['args'] = null;  // FIXME: not implement
    node['storageKey'] = null;  // FIXME: not implement
    this._fillFieldKind(node, nodeName, onType);
    if (node['kind'] != 'ScalarField') {
      String typeName = this._getTypeName(nodeName, onType);
      node['selections'] = this._selectionsHandle(field.selectionSet, typeName);
    }
    return node;
  }

  void _fillFieldKind(GeneratedNode node, String name, String nodeName) {
    final object = this._getGraphqlObject(nodeName);
    invariant(object != null, 'SelectorGenerator: can not fill field on $nodeName in ${this._allTypes.keys}');
    final field = object.fields.where((field) => field.name == name).first;
    invariant(field != null, 'Object $nodeName does not have field $name');
    final fieldType = field.type;
    if (fieldType is GraphQLListType) {
      node['kind'] = 'LinkedField';
      node['plural'] = true;
    } else if (fieldType is GraphQLObjectType) {
      node['kind'] = 'LinkedField';
      node['plural'] = false;
    } else if (fieldType is GraphQLScalarType) {
      node['kind'] = 'ScalarField';
    }
    else {
      throw 'not implemented GraphQLType: $fieldType';
    }
  }

  GraphQLObjectType _getGraphqlObject(String typeName) {
    final object = this._allTypes[typeName];
    invariant(field != null, 'Object $typeName does not have exist in ${this._allTypes.keys}');
    return object;
  }

  String _getTypeName(String fieldName, String onType) {
    final object = this._getGraphqlObject(onType);
    final field = object.fields.singleWhere((o) => o.name == fieldName);
    invariant(field != null, 'SelectorGenerator: field $fieldName not exist on type $onType');
    return field.type.name;
  }

}




class GeneratedNode extends RelayObject {}
