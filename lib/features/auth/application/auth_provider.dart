import 'package:finalyearproject/core/network/api_client_provider.dart';
import 'package:finalyearproject/features/auth/data/auth_repository.dart';
import 'package:finalyearproject/features/auth/data/auth_remote_data_source.dart';
import 'package:finalyearproject/features/auth/domain/auth_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(AuthRemoteDataSource(ref.watch(apiClientProvider))),
);

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.isBootstrapping = true,
    this.error,
  });

  final AppUser? user;
  final bool isLoading;
  final bool isBootstrapping;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    bool? isBootstrapping,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState()) {
    bootstrap();
  }

  final AuthRepository _repo;

  Future<void> bootstrap() async {
    try {
      final user = await _repo.loadSession();
      state = AuthState(user: user, isBootstrapping: false);
    } catch (_) {
      await _repo.logout();
      state = const AuthState(isBootstrapping: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.login(email, password);
      state = AuthState(user: result.user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.register(payload);
      state = AuthState(user: result.user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyEmail(String email, String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.verifyEmail(email, code);
      state = AuthState(user: result.user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(isBootstrapping: false);
  }

  void setUser(AppUser user) => state = state.copyWith(user: user);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);
