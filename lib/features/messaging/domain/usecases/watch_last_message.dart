import '../entities/message.dart';
import '../repositories/message_repository.dart';

/// Streams just the most recent message of a conversation (or null if
/// none yet). Powers the preview line in the conversations list.
class WatchLastMessage {
  final MessageRepository repository;
  const WatchLastMessage(this.repository);

  Stream<Message?> call(String applicationId) =>
      repository.watchLastMessage(applicationId);
}