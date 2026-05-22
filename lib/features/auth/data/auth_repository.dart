import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/features/auth/data/auth_remote_data_source.dart';
import 'package:finalyearproject/features/auth/domain/auth_models.dart';

class AuthRepository {
  AuthRepository(this._remote);
  final AuthRemoteDataSource _remote;

  Future<AuthResult> login(String email, String password) async {
    final result = await _remote.login(email, password);
    await saveAccessToken(result.token);
    return result;
  }

  Future<AuthResult> register(Map<String, dynamic> payload) =>
      _remote.register(payload).then((r) async {
        await saveAccessToken(r.token);
        return r;
      });

  Future<AuthResult> registerWithImage({
    required Map<String, String> fields,
    List<int>? imageBytes,
    String? imageName,
  }) =>
      _remote.registerWithImage(fields: fields, imageBytes: imageBytes, imageName: imageName).then((r) async {
        await saveAccessToken(r.token);
        return r;
      });

  Future<AppUser?> loadSession() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return null;
    return _remote.getProfile();
  }

  Future<AppUser> updateProfile(Map<String, String> fields, {List<int>? imageBytes, String? imageName}) =>
      _remote.updateProfile(fields, imageBytes: imageBytes, imageName: imageName);

  Future<void> changePassword(String current, String newPass) =>
      _remote.changePassword(current, newPass);

  Future<void> requestPasswordReset(String email) => _remote.requestPasswordReset(email);

  Future<void> resetPassword(String token, String newPass) =>
      _remote.resetPassword(token, newPass);

  Future<AuthResult> verifyEmail(String email, String code) =>
      _remote.verifyEmail(email, code).then((r) async {
        await saveAccessToken(r.token);
        return r;
      });

  Future<void> logout() async {
    await _remote.logout();
    await clearAccessToken();
  }
}
