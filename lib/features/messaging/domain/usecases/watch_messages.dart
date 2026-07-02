import '../entities/message.dart';
import '../repositories/message_repository.dart';

class WatchMessages {
  final MessageRepository repository;
  const WatchMessages(this.repository);

  Stream<List<Message>> call(String applicationId) =>
      repository.watchMessages(applicationId);
}