import '../entities/application.dart';
import '../repositories/application_repository.dart';

/// Streams every application submitted to the given startup.
/// The mirror image of WatchMyApplications — this is what lets a
/// startup admin see and reply to conversations.
class WatchApplicationsForStartup {
  final ApplicationRepository repository;
  const WatchApplicationsForStartup(this.repository);

  Stream<List<Application>> call(String startupName) =>
      repository.watchApplicationsForStartup(startupName);
}