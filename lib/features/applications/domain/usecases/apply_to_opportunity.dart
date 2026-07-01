import '../entities/application.dart';
import '../repositories/application_repository.dart';

class ApplyToOpportunity {
  final ApplicationRepository repository;
  const ApplyToOpportunity(this.repository);

  Future<void> call(Application application) =>
      repository.applyToOpportunity(application);
}