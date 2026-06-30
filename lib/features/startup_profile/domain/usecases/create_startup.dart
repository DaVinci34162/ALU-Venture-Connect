import '../entities/startup.dart';
import '../repositories/startup_repository.dart';

class CreateStartup {
  final StartupRepository repository;
  CreateStartup(this.repository);
  Future<void> call(Startup startup) => repository.createStartup(startup);
}