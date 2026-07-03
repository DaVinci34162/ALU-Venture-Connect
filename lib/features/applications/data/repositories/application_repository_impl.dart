import '../../domain/entities/application.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_firestore_datasource.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationFirestoreDatasource datasource;
  const ApplicationRepositoryImpl(this.datasource);

  @override
  Future<void> applyToOpportunity(Application application) =>
      datasource.applyToOpportunity(application);

  @override
  Stream<List<Application>> watchMyApplications(String studentId) =>
      datasource.watchMyApplications(studentId);

  @override
  Stream<List<Application>> watchApplicationsForStartup(String ownerUid) =>
      datasource.watchApplicationsForStartup(ownerUid);
}