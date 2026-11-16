import 'dart:convert';
import 'dart:io';

void logI18nDebug({
  required String runId,
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, dynamic>? data,
}) {
  final payload = <String, dynamic>{
    'sessionId': 'c052d7',
    'runId': runId,
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data ?? <String, dynamic>{},
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
  try {
    File('debug-c052d7.log')
        .writeAsStringSync('${jsonEncode(payload)}\n', mode: FileMode.append, flush: true);
  } catch (_) {}
}
