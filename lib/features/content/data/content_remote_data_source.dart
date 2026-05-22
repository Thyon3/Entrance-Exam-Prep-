import 'package:finalyearproject/core/network/api_client.dart';

class ContentRemoteDataSource {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> getConcepts(String topicId) async {
    final data = await _api.get('/content/topics/$topicId/concepts', auth: false);
    return data is List ? data : [];
  }

  Future<dynamic> createConcept(String topicId, Map<String, dynamic> body) =>
      _api.post('/content/topics/$topicId/concepts', body: body);

  Future<dynamic> updateConcept(String conceptId, Map<String, dynamic> body) =>
      _api.put('/content/concepts/$conceptId', body: body);

  Future<void> deleteConcept(String conceptId) =>
      _api.delete('/content/concepts/$conceptId');

  Future<List<dynamic>> getVideos(String topicId) async {
    final data = await _api.get('/content/topics/$topicId/videos', auth: false);
    return data is List ? data : [];
  }

  Future<dynamic> createVideo(String topicId, Map<String, dynamic> body) =>
      _api.post('/content/topics/$topicId/videos', body: body);

  Future<dynamic> updateVideo(String videoId, Map<String, dynamic> body) =>
      _api.put('/content/videos/$videoId', body: body);

  Future<void> deleteVideo(String videoId) => _api.delete('/content/videos/$videoId');

  Future<List<dynamic>> getExercises(String topicId) async {
    final data = await _api.get('/exercises/topics/$topicId/exercises', auth: false);
    return data is List ? data : [];
  }

  Future<dynamic> submitExercise(String exerciseId, dynamic answer) =>
      _api.post('/exercises/$exerciseId/submit', body: {'submittedAnswer': answer});

  Future<dynamic> submitExerciseProblem(String problemId, dynamic answer) =>
      _api.post('/exercises/problems/$problemId/submit', body: {'submittedAnswer': answer});

  Future<List<dynamic>> getQuizzes(String topicId) async {
    final data = await _api.get('/quizzes/topics/$topicId/quizzes', auth: false);
    return data is List ? data : [];
  }

  Future<dynamic> getQuiz(String quizId) => _api.get('/quizzes/$quizId');

  Future<dynamic> startQuiz(String quizId) => _api.post('/quizzes/$quizId/start');

  Future<dynamic> submitQuiz(String quizId, List<Map<String, dynamic>> answers) =>
      _api.post('/quizzes/$quizId/submit', body: {'answers': answers});

  Future<dynamic> validateQuizProblem(String problemId, dynamic answer) =>
      _api.post('/quizzes/problems/$problemId/validate', body: {'submittedAnswer': answer});

  Future<List<dynamic>> getExamPapersBySubject(String subjectId) async {
    final data = await _api.get('/exams/papers/subjects/$subjectId', auth: false);
    return data is List ? data : [];
  }

  Future<List<dynamic>> getExamQuestions(String paperId) async {
    final data = await _api.get('/exams/papers/$paperId/questions', auth: false);
    return data is List ? data : [];
  }

  Future<dynamic> validateExamQuestion(String questionId, dynamic answer) =>
      _api.post('/exams/questions/$questionId/validate', body: {'submittedAnswer': answer});

  Future<dynamic> submitGenericAnswer(Map<String, dynamic> payload) =>
      _api.post('/answers', body: payload);
}
