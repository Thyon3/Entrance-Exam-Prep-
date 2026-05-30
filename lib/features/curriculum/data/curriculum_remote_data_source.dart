import 'package:finalyearproject/core/network/api_client.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';

class CurriculumRemoteDataSource {
  CurriculumRemoteDataSource(this._api);
  final ApiClient _api;

  Future<List<SubjectModel>> getSubjects() async {
    final data = await _api.get('/subjects', auth: false);
    return parseList(data, SubjectModel.fromJson);
  }

  Future<SubjectModel> getSubject(String id) async {
    final data = await _api.get('/subjects/$id', auth: false);
    return SubjectModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<ChapterModel>> getChaptersBySubject(String subjectId) async {
    final data = await _api.get('/content/subjects/$subjectId/chapters', auth: false);
    return parseList(data, ChapterModel.fromJson);
  }

  Future<ChapterModel> getChapter(String chapterId) async {
    final data = await _api.get('/content/chapters/$chapterId', auth: false);
    return ChapterModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<TopicModel>> getTopicsByChapter(String chapterId) async {
    final data = await _api.get('/content/chapters/$chapterId/topics', auth: false);
    return parseList(data, TopicModel.fromJson);
  }

  Future<TopicModel> getTopic(String topicId) async {
    final data = await _api.get('/content/topics/$topicId', auth: false);
    return TopicModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<TopicModel>> searchTopics(String q) async {
    final data = await _api.get('/content/topics/search', query: {'q': q});
    return parseList(data, TopicModel.fromJson);
  }

  Future<ChapterModel> createChapter(String subjectId, Map<String, dynamic> body) async {
    final data = await _api.post('/content/chapters', body: {...body, 'subjectId': subjectId});
    return ChapterModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<ChapterModel> updateChapter(String chapterId, Map<String, dynamic> body) async {
    final data = await _api.put('/content/chapters/$chapterId', body: body);
    return ChapterModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> deleteChapter(String chapterId) => _api.delete('/content/chapters/$chapterId');

  Future<TopicModel> createTopic(String chapterId, Map<String, dynamic> body) async {
    final data = await _api.post('/content/topics', body: {...body, 'chapterId': chapterId});
    return TopicModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<TopicModel> updateTopic(String topicId, Map<String, dynamic> body) async {
    final data = await _api.put('/content/topics/$topicId', body: body);
    return TopicModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> deleteTopic(String topicId) => _api.delete('/content/topics/$topicId');
}
