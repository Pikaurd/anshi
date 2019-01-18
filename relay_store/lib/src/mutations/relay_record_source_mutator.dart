import 'package:quiver/core.dart';

import '../store/relay_store_types.dart';

/**
 * @internal
 *
 * Wrapper API that is an amalgam of the `RelayModernRecord` API and
 * `MutableRecordSource` interface, implementing copy-on-write semantics for
 * records in a record source. If a `backup` is supplied, the mutator will
 * ensure that the backup contains sufficient information to revert all
 * modifications by publishing the backup.
 *
 * Modifications are applied to fresh copies of records with optional backups
 * created:
 * - Records in `base` are never modified.
 * - Modifications cause a fresh version of a record to be created in `sink`.
 *   These sink records contain only modified fields.
 * - If a `backup` is supplied, any modifications to a record will cause the
 *   sink version of the record to be added to the backup.
 * - Creation of a record causes a sentinel object to be added to the backup
 *   so that the new record can be removed from the store by publishing the
 *   backup.
 */
class RelayRecordSourceMutator {
  Optional<MutableRecordSource> _backup;
  RecordSource _base;
  MutableRecordSource _sink;
  List<RecordSource> __sources;

  RelayRecordSourceMutator(RecordSource base, MutableRecordSource sink, MutableRecordSource backup) {
    this._base = base;
    this._sink = sink;
    this._backup = Optional.fromNullable(backup);
    this.__sources = [sink, base];
  }

  void _createBackupRecord(String dataID) {
    if (_backup.isEmpty) return;

    final backup = _backup.value;
    if (backup.has(dataID)) {
      final baseRecord = _base.get(dataID);
      if (baseRecord.isNotEmpty) {
        backup.set(dataID, baseRecord.value);
      } else {
        backup.delete(dataID);
      }
    }
  }

  void _setSentinelFieldsInBackupRecord(String dataID, Record record) {
    if (_backup.isEmpty) return;

    final backupRecord = _backup.value.get(dataID);
    
  }

}
