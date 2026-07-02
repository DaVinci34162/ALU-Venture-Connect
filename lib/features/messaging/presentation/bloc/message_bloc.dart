import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/watch_messages.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final WatchMessages watchMessages;
  final SendMessage sendMessage;

  MessageBloc({
    required this.watchMessages,
    required this.sendMessage,
  }) : super(const MessageState()) {
    on<WatchMessagesStarted>(_onWatchStarted);
    on<MessageSent>(_onMessageSent);
    on<MessageErrorOccurred>(_onError);
  }

  Future<void> _onWatchStarted(
      WatchMessagesStarted event, Emitter<MessageState> emit) async {
    emit(state.copyWith(isLoading: true));
    await emit.forEach(
      watchMessages(event.applicationId),
      onData: (messages) => state.copyWith(
        messages: messages,
        isLoading: false,
      ),
      onError: (error, _) => state.copyWith(
        isLoading: false,
        error: error.toString(),
      ),
    );
  }

  Future<void> _onMessageSent(
      MessageSent event, Emitter<MessageState> emit) async {
    emit(state.copyWith(isSending: true));
    try {
      await sendMessage(
        applicationId: event.applicationId,
        message: Message(
          id: '',
          senderId: event.senderId,
          senderName: event.senderName,
          text: event.text,
          sentAt: DateTime.now(),
        ),
      );
      emit(state.copyWith(isSending: false));
    } catch (e) {
      debugPrint('MessageBloc: send error: $e');
      emit(state.copyWith(isSending: false, error: e.toString()));
    }
  }

  void _onError(MessageErrorOccurred event, Emitter<MessageState> emit) {
    emit(state.copyWith(isLoading: false, error: event.message));
  }
}