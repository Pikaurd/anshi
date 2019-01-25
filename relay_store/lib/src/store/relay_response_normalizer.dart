import './relay_store_types.dart';
import '../util/normalization_node.dart';
import '../util/invariant.dart';
import 'relay_store_utils.dart';
import '../util/dart_relay_node.dart';
import './relay_store_utils.dart';

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
    throw 'not implement';
  }

  void _normalizePluralLink(/* NormalizationLinkedField */RelayObject field, Record record, String storageKey, Map<String, dynamic> fieldValue) {
    throw 'not implement';
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
