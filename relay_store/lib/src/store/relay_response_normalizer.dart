import 'package:quiver/core.dart';

import './relay_store_types.dart';
import '../util/normalization_node.dart';
import '../util/invariant.dart';
import 'relay_store_utils.dart';
import '../util/dart_relay_node.dart';
import './relay_store_utils.dart';
import './relay_record.dart' as RelayRecord;
import './generate_relay_client_id.dart';

const __DEV__ = !bool.fromEnvironment("dart.vm.product");

// NormalizedResponse normalize(MutableRecordSource recordSource, NormalizationSelector selector, Map<String, dynamic> response) {
NormalizedResponse normalize(MutableRecordSource recordSource, NormalizationSelector<GeneratedNode> selector, Map<String, dynamic> response) {
  final dataID = selector.dataID;
  final node = selector.node;
  final variables = selector.variables;
  final normalizer = RelayResponseNormalizer(recordSource, variables, false);
  return normalizer.normalizeResponse(node, dataID, response);
}

class RelayResponseNormalizer {
  List<dynamic> _handleFieldPayloads;
  bool _handleStrippedNulls;
  List<dynamic> _matchFieldPayloads;
  MutableRecordSource _recordSource;
  Variables _variables;

  RelayResponseNormalizer(this._recordSource, this._variables, this._handleStrippedNulls);

  NormalizedResponse normalizeResponse(/*NormalizationNode*/RelayObject node, String dataID, Map<String, dynamic> data) {
    final record = this._recordSource.get(dataID);
    invariant(record.isPresent, 'RelayResponseNormalizer(): Expected root record `$dataID` to exist.'); 
    this._traverseSelections(node, record.value, data);
    return NormalizedResponse(this._handleFieldPayloads, this._matchFieldPayloads);
  }
  
  dynamic _getVariableValue(String name) {
    invariant(this._variables.containsKey(name), 'RelayResponseNormalizer(): Undefined variable `$name`.');
    return this._variables['name'];
  }

  String _getRecordType(Map<String, dynamic> data) {
    final typeName = data[RelayUtilKeys.typenameKey] as String;
    invariant(typeName != null, 'RelayResponseNormalizer(): Expected a typename for record `$data`.');
    return typeName;
  }

  void _traverseSelections(/*NormalizationNode*/RelayObject node, Record record, Map<String, dynamic> data) {
    print('traverse ${node.delegate}');
    final selections = node['selections'] as List<RelayObject>;
    selections.forEach((selection) {
      final kind = selection['kind'];
      if (kind == NormalizationKind.scalarField || kind == NormalizationKind.linkedField) {
        this._normalizeField(node, selection, record, data);
      } else if (kind == NormalizationKind.condition) {
        final conditionValue = this._getVariableValue(selection['condition']);
        if (conditionValue == selection['passingValue']) {
          this._traverseSelections(selection, record, data);
        }
      } else if (kind == NormalizationKind.inlineFragment) {
        throw 'Not implement';
      } else if (kind == NormalizationKind.linkedHandle || kind == NormalizationKind.scalarHandle) {
        throw 'Not implement';
      } else if (kind == NormalizationKind.matchField) {
        this._normalizeMatchField(node, selection, record, data);
      } else if (kind == 'Fragment' || kind == 'FragmentSpread') {
        invariant(false, 'RelayResponseNormalizer(): Unexpected ast kind `$kind`.');
      } else {
        invariant(false, 'RelayResponseNormalizer(): Unexpected ast kind `$kind`.');
      }
    });
  }

  void _normalizeMatchField(/*NormalizationNode*/RelayObject parent, /*NormalizationMatchField*/RelayObject field, Record record, Map<String, dynamic> data) {
    final responseKey = _fieldOr(field['alias'], field['name']);
    final storageKey = getStorageKey(field, this._variables);
    throw '_normalizeMatchField not implemented';
  }

  void _normalizeField(
    /*NormalizationNode*/RelayObject parent, 
    /*NormalizationField*/RelayObject selection, 
    Record record, 
    Map<String, dynamic> data) 
  {
    final responseKey = selection['name'];
    final storageKey = getStorageKey(selection, this._variables);
    final fieldValue = data[responseKey];
    if (fieldValue == null) {
      if (!this._handleStrippedNulls) { return; }
      // FIXME:       RelayModernRecord.setValue(record, storageKey, null);
    }

    final selectionKind = selection['kind'];
    if (selectionKind == NormalizationKind.scalarField) {
      // TODO: handle scalar
    } else if (selectionKind == NormalizationKind.linkedField) {
      if (selection['plural']) {
        this._normalizePluralLink(selection, record, storageKey, fieldValue);
      } else {
        this._normalizeLink(selection, record, storageKey, fieldValue);
      }
    } else if (selectionKind == NormalizationKind.matchField) {
      invariant(false, 'RelayResponseNormalizer(): Unexpected ast kind `$selectionKind` during normalization.');
    } else {
      invariant(false, 'RelayResponseNormalizer(): Unexpected ast kind `$selectionKind` during normalization.');
    }

  }

  void _normalizeLink(/* NormalizationLinkedField */RelayObject field, Record record, String storageKey, Map<String, dynamic> fieldValue) {
    String nextID;
    if (fieldValue.containsKey('id') && fieldValue['id'] != null) {
      nextID = fieldValue['id'];
    } else if (RelayRecord.getLinkedRecordID(record, storageKey).isPresent) {
      nextID = RelayRecord.getLinkedRecordID(record, storageKey).value;
    } else {
      nextID = generateRelayClientID(RelayRecord.getDataID(record), storageKey);
    }
    invariant(nextID is String, 'RelayResponseNormalizer: Expected id on field `$storageKey` to be a string.');

    RelayRecord.setLinkedRecordID(record, storageKey, nextID);
    var nextRecord = this._recordSource.get(nextID);
    if (nextRecord.isEmpty) {
      final typeName = /* TODO: concreteType */ this._getRecordType(fieldValue);
      nextRecord = Optional.of(RelayRecord.create(nextID, typeName));
      this._recordSource.set(nextID, nextRecord.value);
    } else if (__DEV__) {
      this._validateRecordType(nextRecord.value, field, fieldValue);
    }
    this._traverseSelections(field, nextRecord.value, fieldValue);
  }

  void _normalizePluralLink(/* NormalizationLinkedField */RelayObject field, Record record, String storageKey, Map<String, dynamic> fieldValue) {
    throw 'not implement';
  }

  void _validateRecordType(Record record, RelayObject field, Map<String, dynamic> payload) {
    // TODO: not implement
  }

}

class NormalizedResponse {
  final List<dynamic> fieldPayloads;
  final List<dynamic> matchPayloadas;

  NormalizedResponse(this.fieldPayloads, this.matchPayloadas);
}


String _fieldOr(String a, String b) {
  if (a != null) return a;
  return b;
}
