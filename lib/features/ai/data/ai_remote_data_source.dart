import 'package:finalyearproject/core/network/api_client.dart';

class AiRemoteDataSource {
  final ApiClient _api = ApiClient();

  Future<String> chat({
    required String message,
    String? topicId,
    String? page,
  }) async {
    final data = await _api.post('/ai/chat', body: {
      'message': message,
      if (topicId != null) 'topicId': topicId,
      if (page != null) 'page': page,
    });
    if (data is Map && data['answer'] != null) return data['answer'].toString();
    return data?.toString() ?? '';
  }
}
