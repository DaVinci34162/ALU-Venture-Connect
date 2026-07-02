import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';
import '../models/message_model.dart';

class MessageFirestoreDatasource {
  final FirebaseFirestore firestore;
  const MessageFirestoreDatasource(this.firestore);

  Stream<List<Message>> watchMessages(String applicationId) {
    return firestore
        .collection('applications')
        .doc(applicationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => MessageModel.fromDoc(doc)).toList());
  }

  Future<void> sendMessage({
    required String applicationId,
    required Message message,
  }) async {
    final model = MessageModel(
      id: '',
      senderId: message.senderId,
      senderName: message.senderName,
      text: message.text,
      sentAt: message.sentAt,
    );
    await firestore
        .collection('applications')
        .doc(applicationId)
        .collection('messages')
        .add(model.toMap());
  }
}