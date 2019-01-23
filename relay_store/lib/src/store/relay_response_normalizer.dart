import './relay_store_types.dart';
import '../util/normalization_node.dart';
import '../util/invariant.dart';
import 'relay_store_utils.dart';
import './relay_store_utils.dart' as RelayStoreUtils;

NormalizedResponse normalize(MutableRecordSource recordSource, NormalizationSelector selector, Map<String, dynamic> response) {
  return null;
}

class RelayResponseNormalizer {
  List<dynamic> _handleFieldPayloads;
  bool _handleStrippedNulls;
  List<dynamic> _matchFieldPayloads;
  MutableRecordSource _recordSource;
  Variables _variables;

  RelayResponseNormalizer(this._recordSource, this._variables, this._handleStrippedNulls);

  NormalizedResponse normalizeResponse(/*NormalizationNode*/RelayObject node, String dataID, PayloadData data) {
    final record = this._recordSource.get(dataID);
    invariant(record.isPresent, 'RelayResponseNormalizer(): Expected root record `$dataID` to exist.'); 
    this._traverseSelections(node, record.value, data);
    return NormalizedResponse(this._handleFieldPayloads, this._matchFieldPayloads);
  }

  dynamic _getVariableValue(String name) {
    invariant(this._variables.containsKey(name), 'RelayResponseNormalizer(): Undefined variable `$name`.');
    return this._variables['name'];
  }

  String _getRecordType(PayloadData data) {
    final typeName = data[RelayStoreUtils.typenameKey] as String;
    invariant(typeName != null, 'RelayResponseNormalizer(): Expected a typename for record `$data`.');
    return typeName;
  }

  void _traverseSelections(/*NormalizationNode*/RelayObject node, Record record, PayloadData data) {
    final selections = node['selections'] as List<RelayObject>;
    selections.forEach((selection) {
      final kind = selection['kind'] as Symbol;
      if (kind == #scalar_field || kind == #linked_field) {
        this._normalizeField(node, selection, record, data);
      } else if (kind == #condition) {
        final conditionValue = this._getVariableValue(selection['condition']);
        if (conditionValue == selection['passingValue']) {
          this._traverseSelections(selection, record, data);
        }
      } else if (kind == #inline_fragment) {
        throw 'Not implement';
      } else if (kind == #linked_handle || kind == #scalar_handle) {
        throw 'Not implement';
      } else if (kind == #match_field) {
        this._normalizeMatchField(node, selection, record, data);
      } else if (kind == #fragment || kind == #fragment_speard) {
        invariant(false, 'RelayResponseNormalizer(): Unexpected ast kind `$kind`.');
      } else {
        invariant(false, 'RelayResponseNormalizer(): Unexpected ast kind `$kind`.');
      }
    });
  }

  void _normalizeMatchField(/*NormalizationNode*/RelayObject parent, /*NormalizationMatchField*/RelayObject field, Record record, PayloadData data) {
    final responseKey = _fieldOr(field['alias'], field['name']);
    final storageKey = getStorageKey(field, this._variables);
  }



}

class NormalizedResponse {
  final List<dynamic> fieldPayloads;
  final List<dynamic> matchPayloadas;

  NormalizedResponse(this.fieldPayloads, this.matchPayloadas);
}

class PayloadData extends RelayObject {}

String _fieldOr(String a, String b) {
  if (a != null) return a;
  return b;
}
