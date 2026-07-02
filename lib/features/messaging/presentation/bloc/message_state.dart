import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';

class MessageState extends Equatable {
  final List<Message> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const MessageState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  MessageState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return MessageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, isSending, error];
}