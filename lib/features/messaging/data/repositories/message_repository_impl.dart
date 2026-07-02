import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_firestore_datasource.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageFirestoreDatasource datasource;
  const MessageRepositoryImpl(this.datasource);

  @override
  Stream<List<Message>> watchMessages(String applicationId) =>
      datasource.watchMessages(applicationId);

  @override
  Future<void> sendMessage({
    required String applicationId,
    required Message message,
  }) =>
      datasource.sendMessage(
        applicationId: applicationId,
        message: message,
      );
}