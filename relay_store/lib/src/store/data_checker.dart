import 'package:built_collection/built_collection.dart';
import 'package:quiver/core.dart';

import 'relay_store_types.dart';
import '../mutations/relay_record_source_mutator.dart';

bool check(
  RecordSource source, 
  MutableRecordSource target, 
  NormalizationSelector selector,
  BuiltList<MissingFieldHandler> handlers,
  OperationLoader operationLoader
) 
{
  return false;
  // final dataID = selector.dataID;
  // final node = selector.node;
  // final variables = selector.variables;
  // final checker = DataChecker(source, target, variables, handlers, operationLoader);
  // return checker.check(node, dataID);
}

// class DataChecker {
//   Optional<OperationLoader> _operationLoader;
//   BuiltList<MissingFieldHandler> _handlers;
//   RecordSourceMutator _mutator;
//   bool _recordWasMissing;
//   ReadOnlyRecordSourceProxy _recordSourceProxy;
//   RecordSource _source;
//   Variables _variables;

//   DataChecker(RecordSource source, MutableRecordSource target, Variables variables, BuiltList<MissingFieldHandler> handlers, OperationLoader operationLoader) {
//     _operationLoader = Optional.fromNullable(operationLoader);
//     _handlers = handlers;
//     _mutator = RecordSourceMutator(source, target);
//     _recordWasMissing = false;
//     _source = source;
//     _variables = variables;
//     _recordSourceProxy = RecordSourceProxy(_mutator);
//   }
// }
