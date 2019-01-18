import 'package:built_collection/built_collection.dart';
import 'package:quiver/collection.dart';

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

Arguments getArgumentValues<T>()
  