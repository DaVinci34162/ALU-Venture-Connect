import '../entities/message.dart';
import '../repositories/message_repository.dart';

class SendMessage {
  final MessageRepository repository;
  const SendMessage(this.repository);

  Future<void> call({
    required String applicationId,
    required Message message,
  }) =>
      repository.sendMessage(
        applicationId: applicationId,
        message: message,
      );
}