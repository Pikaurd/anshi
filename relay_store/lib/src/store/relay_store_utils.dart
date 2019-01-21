import 'dart:convert';
import 'package:built_collection/built_collection.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';
import '../util/normalization_node.dart';
import './relay_store_types.dart';

const String fragmentsKey = '__fragments';
const String fragmentPropNameKey = '__fragmentPropName';
const String matchComponentKey = '__match_component';
const String matchFragmentKey = '__match_fragment';
const String idKey = '__id';
const String moduleKey = '__id';
const String refKey = '__id';
const String refsKey = '__id';
const String rootID = '__id';
const String rootType = '__id';
const String typenameKey = '__id';
const Map unpublishRecordSentinel = {};
const Map unpublishFieldSentinel = {};

class Arguments extends DelegatingMap<String, dynamic> {
  Map<String, dynamic> _delegate = {};

  @override
  Map<String, dynamic> get delegate => _delegate;
}

// args: NormalizationArgument | ReaderArgument
Arguments getArgumentValues(List<dynamic> args, Variables variables) {
  var values = Arguments();
  args.forEach((arg) {
    if (arg.kind == #varibale) {
      values[arg.name] = getStableVariableValue(arg.variableName, variables);
    } else {
      values[arg.name] = arg.value;
    }
  });
  return values;
}

String getHandleStorageKey(NormalizationHandle handleField, Variables variables) {
  /**
  const {handle, key, name, args, filters} = handleField;
  const handleName = getRelayHandleKey(handle, key, name);
  if (!args || !filters || args.length === 0 || filters.length === 0) {
    return handleName;
  }
  const filterArgs = args.filter(arg => filters.indexOf(arg.name) > -1);
  return formatStorageKey(handleName, getArgumentValues(filterArgs, variables));
   */
  final handle = handleField.handle;
  final key = handleField.key;
  final name = handleField.name;
  final args = handleField.args;
  final filters = handleField.filters;

  final handleName = getRelayHandleKey(handle, key, name);
  
  
  final emptyList = BuiltList();
  if (!args.isPresent || !filters.isPresent || args.or(emptyList).length == 0 || filters.or(emptyList).length == 0) {
    return handleName;
  }
  final filterArgs = args.value.where((arg) => filters.value.contains(arg.name));
  final argValues = filterArgs.fold({}, (acc, e) => acc[e.name] = e);
  return formatStorageKey(handleName, argValues);
}

/*
function getStorageKey(
  field: NormalizationField | NormalizationHandle | ReaderField,
  variables: Variables,
): string {
  if (field.storageKey) {
    // TODO T23663664: Handle nodes do not yet define a static storageKey.
    return (field: $FlowFixMe).storageKey;
  }
  const {args, name} = field;
  return args && args.length !== 0
    ? formatStorageKey(name, getArgumentValues(args, variables))
    : name;
}
 */
String getStorageKey(dynamic field, Variables variables) {
  final args = field.args;
  final name = field.name;
  
}

/*
function formatStorageKey(name: string, argValues: ?Arguments): string {
  if (!argValues) {
    return name;
  }
  const values = [];
  for (const argName in argValues) {
    if (argValues.hasOwnProperty(argName)) {
      const value = argValues[argName];
      if (value != null) {
        values.push(argName + ':' + JSON.stringify(value));
      }
    }
  }
  return values.length === 0 ? name : name + `(${values.join(',')})`;
}
 */
String formatStorageKey(String name, Arguments argValues) {
  if (argValues == null) return name;
  final jsonEncoder = JsonEncoder();

  var values = [];
  for (var argName in argValues.keys) {
    final value = argValues[argName];
    if (value != null) {
      final v = jsonEncoder.convert(value);
      values.add('$argName:$v');
    }
  }

  return values.length == 0 ? name : name + values.join(',');
}

String getRelayHandleKey(String handleName, String key, String fieldName) {
  if (key != null && key != '') {
    return '__${key}_${handleName}';
  }

  assert(fieldName != null);
  return '__${fieldName}_${handleName}';
}

dynamic getStableVariableValue(String name, Variables variables) {
  return variables[name];
}
