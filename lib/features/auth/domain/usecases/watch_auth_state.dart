import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState {
  final AuthRepository repository;
  WatchAuthState(this.repository);

  Stream<AppUser?> call() => repository.watchAuthState();
}