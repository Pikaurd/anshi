const PREFIX = 'client:';

String generateRelayClientID(String id, String storageKey, [int index]) {
  String key = '$id:$storageKey';
  if (index != null) {
    key += ':$index';
  }
  if (!key.startsWith(PREFIX)) {
    key = PREFIX + key;
  }
  return key;
}
