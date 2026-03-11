part of 'chat_cubit.dart';

enum ChatStatus { initial, loading, success, error }

class ChatState {
  final ChatStatus status;
  final List<ChatUser> chats;
  final Map<String, dynamic>? currentChatData;
  final List<MessageModel> messages;
  final String? errorMessage;
  final String? successMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.chats = const [],
    this.currentChatData,
    this.messages = const [],
    this.errorMessage,
    this.successMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatUser>? chats,
    Map<String, dynamic>? currentChatData,
    List<MessageModel>? messages,
    String? errorMessage,
    String? successMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      currentChatData: currentChatData ?? this.currentChatData,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

class ChatUser {
  final String userId;
  final String name;
  final String? photoUrl;
  final String? university;
  final String lastMessage;
  final Timestamp? lastMessageTime;
  final bool isRead;
  final String chatId;

  ChatUser({
    required this.userId,
    required this.name,
    this.photoUrl,
    this.university,
    required this.lastMessage,
    this.lastMessageTime,
    required this.isRead,
    required this.chatId,
  });

  String get formattedTime {
    if (lastMessageTime == null) return '';
    
    DateTime dateTime = lastMessageTime!.toDate();
    DateTime now = DateTime.now();

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.day == now.day - 1 &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}