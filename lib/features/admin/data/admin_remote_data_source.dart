import 'package:finalyearproject/core/network/api_client.dart';

class AdminRemoteDataSource {
  AdminRemoteDataSource(this._api);
  final ApiClient _api;

  Future<dynamic> listUsers({Map<String, String>? params}) =>
      _api.get('/admin/users', query: params);

  Future<dynamic> getUser(String userId) => _api.get('/admin/users/$userId');

  Future<void> updateUserStatus(String userId, String status) =>
      _api.patch('/admin/users/$userId/status', body: {'status': status});

  Future<dynamic> createSubject(Map<String, dynamic> body) =>
      _api.post('/subjects', body: body);

  Future<dynamic> updateSubject(String id, Map<String, dynamic> body) =>
      _api.put('/subjects/$id', body: body);

  Future<void> deleteSubject(String id) => _api.delete('/subjects/$id');

  Future<dynamic> inviteAssignTeacher(String subjectId, Map<String, dynamic> body) =>
      _api.post('/subjects/$subjectId/invite-assign-teacher', body: body);
}
