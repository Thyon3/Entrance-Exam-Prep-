import 'package:finalyearproject/core/network/api_client.dart';

class EngagementRemoteDataSource {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> getUnreadNotifications() async {
    final data = await _api.get('/notifications/unread');
    return data is List ? data : [];
  }

  Future<List<dynamic>> getAllNotifications() async {
    final data = await _api.get('/notifications');
    return data is List ? data : [];
  }

  Future<void> markNotificationRead(String id) =>
      _api.put('/notifications/$id/read');

  Future<List<dynamic>> getBookmarks() async {
    final data = await _api.get('/bookmarks');
    return data is List ? data : [];
  }

  Future<dynamic> addBookmark(Map<String, dynamic> payload) =>
      _api.post('/bookmarks', body: payload);

  Future<void> removeBookmark(String id) => _api.delete('/bookmarks/$id');

  Future<List<dynamic>> getMyIssues() async {
    final data = await _api.get('/issues/me');
    return data is List ? data : [];
  }

  Future<dynamic> createIssue(Map<String, dynamic> payload) =>
      _api.post('/issues', body: payload);

  Future<List<dynamic>> getIssuesForReview({Map<String, String>? params}) async {
    final data = await _api.get('/issues', query: params);
    return data is List ? data : [];
  }

  Future<void> updateIssueStatus(String issueId, String status) =>
      _api.put('/issues/$issueId/status', body: {'issueStatus': status});

  Future<List<dynamic>> getSubjectProgress() async {
    final data = await _api.get('/progress/subjects');
    return data is List ? data : [];
  }

  Future<dynamic> getGradeProgress(String gradeLevel) =>
      _api.get('/progress/grades/$gradeLevel');

  Future<dynamic> getLearningStreak({String? gradeLevel}) => _api.get(
        '/progress/streak',
        query: gradeLevel != null ? {'gradeLevel': gradeLevel} : null,
      );

  Future<dynamic> getSubjectChapterProgress(String subjectId) =>
      _api.get('/progress/subjects/$subjectId/chapters');

  Future<dynamic> getTopicEligibility(String topicId) =>
      _api.get('/progress/topics/$topicId/eligibility');

  Future<dynamic> markTopicComplete(String topicId) =>
      _api.post('/progress/topics/$topicId/complete');

  Future<List<dynamic>> listQuestions({Map<String, String>? params}) async {
    final data = await _api.get('/questions', query: params);
    return data is List ? data : [];
  }

  Future<List<dynamic>> getTopicQuestions(String topicId) async {
    final data = await _api.get('/questions/topics/$topicId');
    return data is List ? data : [];
  }

  Future<dynamic> askQuestion(Map<String, dynamic> payload) =>
      _api.post('/questions', body: payload);

  Future<List<dynamic>> getQuestionAnswers(String questionId) async {
    final data = await _api.get('/questions/$questionId/answers');
    return data is List ? data : [];
  }

  Future<dynamic> answerQuestion(String questionId, String content) =>
      _api.post('/questions/$questionId/answers', body: {'content': content});
}
