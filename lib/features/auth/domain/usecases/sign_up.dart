import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;
  SignUp(this.repository);

  Future<AppUser> call({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) {
    return repository.signUp(email: email, password: password, name: name, role: role);
  }
}