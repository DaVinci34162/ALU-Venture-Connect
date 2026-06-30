import '../../domain/entities/startup.dart';
import '../../domain/repositories/startup_repository.dart';
import '../datasources/startup_firestore_datasource.dart';
import '../models/startup_model.dart';

class StartupRepositoryImpl implements StartupRepository {
  final StartupFirestoreDataSource dataSource;
  StartupRepositoryImpl(this.dataSource);

  @override
  Stream<Startup?> watchMyStartup(String uid) => dataSource.watchMyStartup(uid);

  @override
  Future<void> createStartup(Startup startup) {
    return dataSource.create(StartupModel(
      id: startup.id,
      name: startup.name,
      description: startup.description,
      verified: startup.verified,
      createdBy: startup.createdBy,
    ));
  }
}