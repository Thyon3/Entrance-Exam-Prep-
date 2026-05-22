/// Unwraps `{ success, data, message }` envelopes from the Express API.
dynamic unwrapApiData(dynamic body) {
  if (body is Map<String, dynamic>) {
    if (body.containsKey('data')) return body['data'];
    return body;
  }
  return body;
}

String extractApiMessage(dynamic body, [String fallback = 'Request failed']) {
  if (body is Map<String, dynamic>) {
    if (body['message'] is String) return body['message'] as String;
    if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
      final first = (body['errors'] as List).first;
      if (first is Map && first['msg'] != null) return first['msg'].toString();
    }
  }
  return fallback;
}
