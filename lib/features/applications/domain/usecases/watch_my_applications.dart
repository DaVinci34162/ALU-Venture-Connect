import '../entities/application.dart';
import '../repositories/application_repository.dart';

class WatchMyApplications {
  final ApplicationRepository repository;
  const WatchMyApplications(this.repository);

  Stream<List<Application>> call(String studentId) =>
      repository.watchMyApplications(studentId);
}