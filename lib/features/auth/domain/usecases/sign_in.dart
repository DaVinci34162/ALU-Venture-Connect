import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;
  SignIn(this.repository);

  Future<AppUser> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}