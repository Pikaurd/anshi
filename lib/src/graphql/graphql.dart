// copy from: https://github.com/angel-dart/graphql/blob/master/graphql_server/lib/graphql_server.dart

import 'dart:async';

import 'package:graphql_parser/graphql_parser.dart';
import 'package:graphql_schema/graphql_schema.dart';

import 'introspection.dart';

Map<String, dynamic> foldToStringDynamic(Map map) {
  return map == null
      ? null
      : map.keys.fold<Map<String, dynamic>>(
          <String, dynamic>{}, (out, k) => out..[k.toString()] = map[k]);
}

class GraphQL {
  final List<GraphQLType> customTypes = [];
  GraphQLSchema _schema;

  GraphQL(GraphQLSchema schema,
      {bool introspect: true,
      List<GraphQLType> customTypes = const <GraphQLType>[]})
      : _schema = schema {
    if (customTypes?.isNotEmpty == true) {
      this.customTypes.addAll(customTypes);
    }

    if (introspect) {
      var allTypes = <GraphQLType>[];
      allTypes.addAll(this.customTypes);
      _schema = reflectSchema(_schema, allTypes);

      for (var type in allTypes.toSet()) {
        if (!this.customTypes.contains(type)) {
          this.customTypes.add(type);
        }
      }
    }

    if (_schema.queryType != null) this.customTypes.add(_schema.queryType);
    if (_schema.mutationType != null)
      this.customTypes.add(_schema.mutationType);
  }

  GraphQLType convertType(TypeContext ctx) {
    if (ctx.listType != null) {
      return new GraphQLListType(convertType(ctx.listType.type));
    } else if (ctx.typeName != null) {
      switch (ctx.typeName.name) {
        case 'Int':
          return graphQLString;
        case 'Float':
          return graphQLFloat;
        case 'String':
          return graphQLString;
        case 'Boolean':
          return graphQLBoolean;
        case 'ID':
          return graphQLId;
        case 'Date':
        case 'DateTime':
          return graphQLDate;
        default:
          return customTypes.firstWhere((t) => t.name == ctx.typeName.name,
              orElse: () => throw new ArgumentError(
                  'Unknown GraphQL type: "${ctx.typeName.name}"'));
      }
    } else {
      throw new ArgumentError('Invalid GraphQL type: "${ctx.span.text}"');
    }
  }

  Future<Map<String, dynamic>> parseAndExecute(String text,
      {String operationName,
      sourceUrl,
      Map<String, dynamic> variableValues: const {},
      initialValue,
      Map<String, dynamic> globalVariables}) {
    var tokens = scan(text, sourceUrl: sourceUrl);
    var parser = new Parser(tokens);
    var document = parser.parseDocument();

    if (parser.errors.isNotEmpty) {
      throw new GraphQLException(parser.errors
          .map((e) => new GraphQLExceptionError(e.message, locations: [
                new GraphExceptionErrorLocation.fromSourceLocation(e.span.start)
              ]))
          .toList());
    }

    return executeRequest(
      _schema,
      document,
      operationName: operationName,
      initialValue: initialValue,
      variableValues: variableValues,
      globalVariables: globalVariables,
    );
  }

  Future<Map<String, dynamic>> executeRequest(
      GraphQLSchema schema, DocumentContext document,
      {String operationName,
      Map<String, dynamic> variableValues: const <String, dynamic>{},
      initialValue,
      Map<String, dynamic> globalVariables: const <String, dynamic>{}}) async {
    var operation = getOperation(document, operationName);
    var coercedVariableValues = coerceVariableValues(
        schema, operation, variableValues ?? <String, dynamic>{});
    if (operation.isQuery)
      return await executeQuery(document, operation, schema,
          coercedVariableValues, initialValue, globalVariables);
    else {
      return executeMutation(document, operation, schema, coercedVariableValues,
          initialValue, globalVariables);
    }
  }

  OperationDefinitionContext getOperation(
      DocumentContext document, String operationName) {
    var ops =
        document.definitions.where((d) => d is OperationDefinitionContext);

    if (operationName == null) {
      return ops.length == 1
          ? ops.first as OperationDefinitionContext
          : throw new GraphQLException.fromMessage(
              'This document does not define any operations.');
    } else {
      return ops.firstWhere(
              (d) => (d as OperationDefinitionContext).name == operationName,
              orElse: () => throw new GraphQLException.fromMessage(
                  'Missing required operation "$operationName".'))
          as OperationDefinitionContext;
    }
  }

  Map<String, dynamic> coerceVariableValues(
      GraphQLSchema schema,
      OperationDefinitionContext operation,
      Map<String, dynamic> variableValues) {
    var coercedValues = <String, dynamic>{};
    var variableDefinitions =
        operation.variableDefinitions?.variableDefinitions ?? [];

    for (var variableDefinition in variableDefinitions) {
      var variableName = variableDefinition.variable.name;
      var variableType = variableDefinition.type;
      var defaultValue = variableDefinition.defaultValue;
      var value = variableValues[variableName];

      if (value == null) {
        if (defaultValue != null) {
          coercedValues[variableName] = defaultValue.value.value;
        } else if (!variableType.isNullable) {
          throw new GraphQLException.fromSourceSpan(
              'Missing required variable "$variableName".',
              variableDefinition.span);
        }
      } else {
        var type = convertType(variableType);
        var validation = type.validate(variableName, value);

        if (!validation.successful) {
          throw new GraphQLException(validation.errors
              .map((e) => new GraphQLExceptionError(e, locations: [
                    new GraphExceptionErrorLocation.fromSourceLocation(
                        variableDefinition.span.start)
                  ]))
              .toList());
        } else {
          coercedValues[variableName] = type.deserialize(value);
        }
      }
    }

    return coercedValues;
  }

  Future<Map<String, dynamic>> executeQuery(
      DocumentContext document,
      OperationDefinitionContext query,
      GraphQLSchema schema,
      Map<String, dynamic> variableValues,
      initialValue,
      Map<String, dynamic> globalVariables) async {
    var queryType = schema.queryType;
    var selectionSet = query.selectionSet;
    return await executeSelectionSet(document, selectionSet, queryType,
        initialValue, variableValues, globalVariables);
  }

  Future<Map<String, dynamic>> executeMutation(
      DocumentContext document,
      OperationDefinitionContext mutation,
      GraphQLSchema schema,
      Map<String, dynamic> variableValues,
      initialValue,
      Map<String, dynamic> globalVariables) async {
    var mutationType = schema.mutationType;

    if (mutationType == null) {
      throw new GraphQLException.fromMessage(
          'The schema does not define a mutation type.');
    }

    var selectionSet = mutation.selectionSet;
    return await executeSelectionSet(document, selectionSet, mutationType,
        initialValue, variableValues, globalVariables);
  }

  Future<Map<String, dynamic>> executeSelectionSet(
      DocumentContext document,
      SelectionSetContext selectionSet,
      GraphQLObjectType objectType,
      objectValue,
      Map<String, dynamic> variableValues,
      Map<String, dynamic> globalVariables) async {
    var groupedFieldSet =
        collectFields(document, objectType, selectionSet, variableValues);
    var resultMap = <String, dynamic>{};

    for (var responseKey in groupedFieldSet.keys) {
      var fields = groupedFieldSet[responseKey];

      for (var field in fields) {
        var fieldName = field.field.fieldName.name;
        var responseValue;

        if (fieldName == '__typename') {
          responseValue = objectType.name;
        } else {
          var fieldType = objectType.fields
              .firstWhere((f) => f.name == fieldName, orElse: () => null)
              ?.type;
          if (fieldType == null) {
            print('unknowd type: ' + fieldName);
            throw new GraphQLException.fromMessage(
              'Cannot query field "$fieldName" on type "${objectType.name}".');
          }
          responseValue = await executeField(
              document,
              fieldName,
              objectType,
              objectValue,
              fields,
              fieldType,
              new Map<String, dynamic>.from(
                  globalVariables ?? <String, dynamic>{})
                ..addAll(variableValues),
              globalVariables);
        }

        resultMap[responseKey] = responseValue;
      }
    }

    return resultMap;
  }

  Future executeField(
      DocumentContext document,
      String fieldName,
      GraphQLObjectType objectType,
      objectValue,
      List<SelectionContext> fields,
      GraphQLType fieldType,
      Map<String, dynamic> variableValues,
      Map<String, dynamic> globalVariables) async {
    var field = fields[0];
    var argumentValues =
        coerceArgumentValues(objectType, field, variableValues);
    var resolvedValue = await resolveFieldValue(
        objectType, objectValue, field.field.fieldName.name, argumentValues);
    return completeValue(document, fieldName, fieldType, fields, resolvedValue,
        variableValues, globalVariables);
  }

  Map<String, dynamic> coerceArgumentValues(GraphQLObjectType objectType,
      SelectionContext field, Map<String, dynamic> variableValues) {
    var coercedValues = <String, dynamic>{};
    var argumentValues = field.field.arguments;
    var fieldName = field.field.fieldName.name;
    var desiredField = objectType.fields.firstWhere((f) => f.name == fieldName);
    var argumentDefinitions = desiredField.inputs;

    for (var argumentDefinition in argumentDefinitions) {
      var argumentName = argumentDefinition.name;
      var argumentType = argumentDefinition.type;
      var defaultValue = argumentDefinition.defaultValue;

      var value = argumentValues.firstWhere((a) => a.name == argumentName,
          orElse: () => null);

      if (value?.valueOrVariable?.variable != null) {
        var variableName = value.valueOrVariable.variable.name;
        var variableValue = variableValues[variableName];

        if (variableValues.containsKey(variableName)) {
          coercedValues[argumentName] = variableValue;
        } else if (defaultValue != null || argumentDefinition.defaultsToNull) {
          coercedValues[argumentName] = defaultValue;
        } else if (argumentType is GraphQLNonNullableType) {
          throw new GraphQLException.fromSourceSpan(
              'Missing value for argument "$argumentName" of field "$fieldName".',
              value.valueOrVariable.span);
        } else {
          continue;
        }
      } else if (value == null) {
        if (defaultValue != null || argumentDefinition.defaultsToNull) {
          coercedValues[argumentName] = defaultValue;
        } else if (argumentType is GraphQLNonNullableType) {
          throw new GraphQLException.fromMessage(
              'Missing value for argument "$argumentName" of field "$fieldName".');
        } else {
          continue;
        }
      } else {
        try {
          var validation = argumentType.validate(
              fieldName, value.valueOrVariable.value.value);

          if (!validation.successful) {
            var errors = <GraphQLExceptionError>[
              new GraphQLExceptionError(
                'Type coercion error for value of argument "$argumentName" of field "$fieldName".',
                locations: [
                  new GraphExceptionErrorLocation.fromSourceLocation(
                      value.valueOrVariable.span.start)
                ],
              )
            ];

            for (var error in validation.errors) {
              errors.add(
                new GraphQLExceptionError(
                  error,
                  locations: [
                    new GraphExceptionErrorLocation.fromSourceLocation(
                        value.valueOrVariable.span.start)
                  ],
                ),
              );
            }

            throw new GraphQLException(errors);
          } else {
            var coercedValue = validation.value;
            coercedValues[argumentName] = coercedValue;
          }
        } on TypeError catch (e) {
          throw new GraphQLException(<GraphQLExceptionError>[
            new GraphQLExceptionError(
              'Type coercion error for value of argument "$argumentName" of field "$fieldName".',
              locations: [
                new GraphExceptionErrorLocation.fromSourceLocation(
                    value.valueOrVariable.span.start)
              ],
            ),
            new GraphQLExceptionError(
              e.message.toString(),
              locations: [
                new GraphExceptionErrorLocation.fromSourceLocation(
                    value.valueOrVariable.span.start)
              ],
            ),
          ]);
        }
      }
    }

    return coercedValues;
  }

  Future<T> resolveFieldValue<T>(GraphQLObjectType objectType, T objectValue,
      String fieldName, Map<String, dynamic> argumentValues) async {
    var field = objectType.fields.firstWhere((f) => f.name == fieldName);

    if (field.resolve == null) {
      return null;
    } else {
      return await field.resolve(objectValue, argumentValues) as T;
    }
  }

  Future completeValue(
      DocumentContext document,
      String fieldName,
      GraphQLType fieldType,
      List<SelectionContext> fields,
      result,
      Map<String, dynamic> variableValues,
      Map<String, dynamic> globalVariables) async {
    if (fieldType is GraphQLNonNullableType) {
      var innerType = fieldType.ofType;
      var completedResult = completeValue(document, fieldName, innerType,
          fields, result, variableValues, globalVariables);

      if (completedResult == null) {
        throw new GraphQLException.fromMessage(
            'Null value provided for non-nullable field "$fieldName".');
      } else {
        return completedResult;
      }
    }

    if (result == null) {
      return null;
    }

    if (fieldType is GraphQLListType) {
      if (result is! Iterable) {
        throw new GraphQLException.fromMessage(
            'Value of field "$fieldName" must be a list or iterable, got $result instead.');
      }

      var innerType = fieldType.ofType;
      var out = [];

      for (var resultItem in (result as Iterable)) {
        out.add(await completeValue(document, '(item in "$fieldName")',
            innerType, fields, resultItem, variableValues, globalVariables));
      }

      return out;
    }

    if (fieldType is GraphQLScalarType) {
      try {
        var validation = fieldType.validate(fieldName, result);

        if (!validation.successful) {
          return null;
        } else {
          return validation.value;
        }
      } on TypeError {
        throw new GraphQLException.fromMessage(
            'Value of field "$fieldName" must be ${fieldType.valueType}, got $result instead.');
      }
    }

    if (fieldType is GraphQLObjectType || fieldType is GraphQLUnionType) {
      GraphQLObjectType objectType;

      if (fieldType is GraphQLObjectType && !fieldType.isInterface) {
        objectType = fieldType;
      } else {
        objectType = resolveAbstractType(fieldName, fieldType, result);
      }

      var subSelectionSet = mergeSelectionSets(fields);
      return await executeSelectionSet(document, subSelectionSet, objectType,
          result, variableValues, globalVariables);
    }

    throw new UnsupportedError('Unsupported type: $fieldType');
  }

  GraphQLObjectType resolveAbstractType(
      String fieldName, GraphQLType type, result) {
    List<GraphQLObjectType> possibleTypes;

    if (type is GraphQLObjectType) {
      if (type.isInterface) {
        possibleTypes = type.possibleTypes;
      } else {
        return type;
      }
    } else if (type is GraphQLUnionType) {
      possibleTypes = type.possibleTypes;
    } else {
      throw new ArgumentError();
    }

    var errors = <GraphQLExceptionError>[];

    for (var t in possibleTypes) {
      try {
        var validation =
            t.validate(fieldName, foldToStringDynamic(result as Map));

        if (validation.successful) {
          return t;
        }

        errors
            .addAll(validation.errors.map((m) => new GraphQLExceptionError(m)));
      } catch (_) {}
    }

    errors.insert(
        0,
        new GraphQLExceptionError(
            'Cannot convert value $result to type $type.'));

    throw new GraphQLException(errors);
  }

  SelectionSetContext mergeSelectionSets(List<SelectionContext> fields) {
    var selections = <SelectionContext>[];

    for (var field in fields) {
      if (field.field?.selectionSet != null) {
        selections.addAll(field.field.selectionSet.selections);
      } else if (field.inlineFragment?.selectionSet != null) {
        selections.addAll(field.inlineFragment.selectionSet.selections);
      }
    }

    return new SelectionSetContext.merged(selections);
  }

  Map<String, List<SelectionContext>> collectFields(
      DocumentContext document,
      GraphQLObjectType objectType,
      SelectionSetContext selectionSet,
      Map<String, dynamic> variableValues,
      {List visitedFragments}) {
    var groupedFields = <String, List<SelectionContext>>{};
    visitedFragments ??= [];

    for (var selection in selectionSet.selections) {
      if (getDirectiveValue('skip', 'if', selection, variableValues) == true)
        continue;
      if (getDirectiveValue('include', 'if', selection, variableValues) ==
          false) continue;

      if (selection.field != null) {
        var responseKey = selection.field.fieldName.name;
        var groupForResponseKey =
            groupedFields.putIfAbsent(responseKey, () => []);
        groupForResponseKey.add(selection);
      } else if (selection.fragmentSpread != null) {
        var fragmentSpreadName = selection.fragmentSpread.name;
        if (visitedFragments.contains(fragmentSpreadName)) continue;
        visitedFragments.add(fragmentSpreadName);
        var fragment = document.definitions
            .where((d) => d is FragmentDefinitionContext)
            .firstWhere(
                (f) =>
                    (f as FragmentDefinitionContext).name == fragmentSpreadName,
                orElse: () => null) as FragmentDefinitionContext;

        if (fragment == null) continue;
        var fragmentType = fragment.typeCondition;
        if (!doesFragmentTypeApply(objectType, fragmentType)) continue;
        var fragmentSelectionSet = fragment.selectionSet;
        var fragmentGroupFieldSet = collectFields(
            document, objectType, fragmentSelectionSet, variableValues);

        for (var responseKey in fragmentGroupFieldSet.keys) {
          var fragmentGroup = fragmentGroupFieldSet[responseKey];
          var groupForResponseKey =
              groupedFields.putIfAbsent(responseKey, () => []);
          groupForResponseKey.addAll(fragmentGroup);
        }
      } else if (selection.inlineFragment != null) {
        var fragmentType = selection.inlineFragment.typeCondition;
        if (fragmentType != null &&
            !doesFragmentTypeApply(objectType, fragmentType)) continue;
        var fragmentSelectionSet = selection.inlineFragment.selectionSet;
        var fragmentGroupFieldSet = collectFields(
            document, objectType, fragmentSelectionSet, variableValues);

        for (var responseKey in fragmentGroupFieldSet.keys) {
          var fragmentGroup = fragmentGroupFieldSet[responseKey];
          var groupForResponseKey =
              groupedFields.putIfAbsent(responseKey, () => []);
          groupForResponseKey.addAll(fragmentGroup);
        }
      }
    }

    return groupedFields;
  }

  getDirectiveValue(String name, String argumentName,
      SelectionContext selection, Map<String, dynamic> variableValues) {
    if (selection.field == null) return null;
    var directive = selection.field.directives.firstWhere((d) {
      var vv = d.valueOrVariable;
      if (vv.value != null) return vv.value.value == name;
      return vv.variable.name == name;
    }, orElse: () => null);

    if (directive == null) return null;
    if (directive.argument?.name != argumentName) return null;

    var vv = directive.argument.valueOrVariable;

    if (vv.value != null) return vv.value.value;

    var vname = vv.variable.name;
    if (!variableValues.containsKey(vname))
      throw new GraphQLException.fromSourceSpan(
          'Unknown variable: "$vname"', vv.span);

    return variableValues[vname];
  }

  bool doesFragmentTypeApply(
      GraphQLObjectType objectType, TypeConditionContext fragmentType) {
    var type = convertType(new TypeContext(fragmentType.typeName, null));
    if (type is GraphQLObjectType && !type.isInterface) {
      for (var field in type.fields)
        if (!objectType.fields.any((f) => f.name == field.name)) return false;
      return true;
    } else if (type is GraphQLObjectType && type.isInterface) {
      return objectType.isImplementationOf(type);
    } else if (type is GraphQLUnionType) {
      return type.possibleTypes.any((t) => objectType.isImplementationOf(t));
    }

    return false;
  }
}
