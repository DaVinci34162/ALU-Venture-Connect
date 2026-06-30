import '../entities/startup.dart';
import '../repositories/startup_repository.dart';

class WatchMyStartup {
  final StartupRepository repository;
  WatchMyStartup(this.repository);
  Stream<Startup?> call(String uid) => repository.watchMyStartup(uid);
}