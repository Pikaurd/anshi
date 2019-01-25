import 'dart:convert';
import 'package:built_collection/built_collection.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';
import '../util/normalization_node_2.dart';
import './relay_store_types.dart';
import '../util/dart_relay_node.dart';

class RelayUtilKeys {
  static const String fragmentsKey = '__fragments';
  static const String fragmentPropNameKey = '__fragmentPropName';
  static const String matchComponentKey = '__match_component';
  static const String matchFragmentKey = '__match_fragment';
  static const String idKey = '__id';
  static const String moduleKey = '__module';
  static const String refKey = '__ref';
  static const String refsKey = '__refs';
  static const String rootID = 'client:root';
  static const String rootType = '__Root';
  static const String typenameKey = '__typename';
  static const Map unpublishRecordSentinel = {'__UNPUBLISH_RECORD_SENTINEL': true};
  static const Map unpublishFieldSentinel = {'__UNPUBLISH_FIELD_SENTINEL': true};
}

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
String getStorageKey(RelayObject field, Variables variables) {
  if (field.containsKey('storageKey') && field['storageKey'] != null) { 
    return field['storageKey']; 
  }

  final args = field['args'] as List<dynamic>;
  final name = field['name'];
  if (args != null && args.length == 0) {
    return '';
  }
  return name;
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
