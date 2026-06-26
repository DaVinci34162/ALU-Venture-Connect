import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Live auth state — lets the app know immediately, app-wide, when
  /// someone signs in or out. This is what decides whether to show the
  /// login screen or the main app.
  Stream<AppUser?> watchAuthState();

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });

  Future<void> signOut();
}