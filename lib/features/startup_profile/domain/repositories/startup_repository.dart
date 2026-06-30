import '../entities/startup.dart';

abstract class StartupRepository {
  Stream<Startup?> watchMyStartup(String uid);
  Future<void> createStartup(Startup startup);
}