import 'package:finalyearproject/core/network/api_client.dart';
import 'package:finalyearproject/features/auth/domain/auth_models.dart';

class AuthRemoteDataSource {
  final ApiClient _api = ApiClient();

  Future<AuthResult> login(String email, String password) async {
    final data = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    );
    return AuthResult.fromEnvelope(data);
  }

  Future<AuthResult> register(Map<String, dynamic> payload) async {
    final data = await _api.post('/auth/register', body: payload, auth: false);
    return AuthResult.fromEnvelope(data);
  }

  Future<AuthResult> registerWithImage({
    required Map<String, String> fields,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    final data = await _api.postMultipart(
      '/auth/register',
      fields: fields,
      fileField: imageBytes != null ? 'profileImageFile' : null,
      fileBytes: imageBytes,
      fileName: imageName,
    );
    return AuthResult.fromEnvelope(data);
  }

  Future<AppUser> getProfile() async {
    final data = await _api.get('/auth/profile');
    if (data is Map<String, dynamic>) return AppUser.fromJson(data);
    throw Exception('Invalid profile response');
  }

  Future<AppUser> updateProfile(Map<String, String> fields, {List<int>? imageBytes, String? imageName}) async {
    final data = await _api.putMultipart(
      '/auth/profile',
      fields: fields,
      fileField: imageBytes != null ? 'profileImageFile' : null,
      fileBytes: imageBytes,
      fileName: imageName,
    );
    if (data is Map<String, dynamic>) return AppUser.fromJson(data);
    throw Exception('Invalid profile response');
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _api.post('/auth/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> requestPasswordReset(String email) async {
    await _api.post('/auth/request-password-reset', body: {'email': email}, auth: false);
  }

  Future<void> resetPassword(String resetToken, String newPassword) async {
    await _api.post('/auth/reset-password', body: {
      'resetToken': resetToken,
      'newPassword': newPassword,
    }, auth: false);
  }

  Future<AuthResult> verifyEmail(String email, String code) async {
    final data = await _api.post(
      '/auth/verify-email',
      body: {'email': email, 'code': code},
      auth: false,
    );
    return AuthResult.fromEnvelope(data);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
  }
}
