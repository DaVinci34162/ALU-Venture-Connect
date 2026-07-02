import '../entities/message.dart';

abstract class MessageRepository {
  Stream<List<Message>> watchMessages(String applicationId);
  Future<void> sendMessage({
    required String applicationId,
    required Message message,
  });
}