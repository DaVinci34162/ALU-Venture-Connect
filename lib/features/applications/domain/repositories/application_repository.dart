import '../entities/application.dart';

abstract class ApplicationRepository {
  Future<void> applyToOpportunity(Application application);
  Stream<List<Application>> watchMyApplications(String studentId);
}