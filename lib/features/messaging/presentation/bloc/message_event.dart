import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();
  @override
  List<Object?> get props => [];
}

class WatchMessagesStarted extends MessageEvent {
  final String applicationId;
  const WatchMessagesStarted(this.applicationId);
  @override
  List<Object?> get props => [applicationId];
}

class MessageSent extends MessageEvent {
  final String applicationId;
  final String senderId;
  final String senderName;
  final String text;
  const MessageSent({
    required this.applicationId,
    required this.senderId,
    required this.senderName,
    required this.text,
  });
  @override
  List<Object?> get props => [applicationId, senderId, senderName, text];
}

class MessageErrorOccurred extends MessageEvent {
  final String message;
  const MessageErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}