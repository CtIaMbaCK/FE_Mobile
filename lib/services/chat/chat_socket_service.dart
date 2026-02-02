import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/chat/message_model.dart';

class ChatSocketService {
  static final ChatSocketService _instance = ChatSocketService._internal();
  factory ChatSocketService() => _instance;
  ChatSocketService._internal();

  IO.Socket? _socket;
  final _storage = const FlutterSecureStorage();

  // Base URL - cần update theo ngrok URL của bạn
  static const String _baseUrl = 'https://frettiest-ariella-unnationally.ngrok-free.dev';

  // Callbacks
  Function(MessageModel)? onNewMessage;
  Function(MessageModel)? onMessageSent;
  Function(String messageId, DateTime readAt)? onMessageRead;
  Function(String conversationId, String userId)? onConversationRead;
  Function(String conversationId, String userId, bool isTyping)? onUserTyping;
  Function(String userId)? onUserOnline;
  Function(String userId)? onUserOffline;
  Function(String error)? onError;

  bool get isConnected => _socket?.connected ?? false;

  // Kết nối Socket.io
  Future<void> connect() async {
    if (_socket?.connected ?? false) {
      print('Socket already connected');
      return;
    }

    try {
      // Lấy token từ secure storage
      final token = await _storage.read(key: 'token');

      if (token == null || token.isEmpty) {
        print('No token found for socket connection');
        return;
      }

      print('Connecting to socket at: $_baseUrl/chat');

      _socket = IO.io(
        '$_baseUrl/chat',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({
              'token': token,
            })
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true',
            })
            .build(),
      );

      // Connection events
      _socket!.onConnect((_) {
        print('✅ Socket connected! ID: ${_socket!.id}');
      });

      _socket!.onConnectError((data) {
        print('❌ Socket connect error: $data');
        if (onError != null) {
          onError!('Kết nối thất bại: $data');
        }
      });

      _socket!.onDisconnect((_) {
        print('❌ Socket disconnected');
      });

      // Message events
      _socket!.on('new_message', (data) {
        print('📩 New message received: ${data['content']}');
        if (onNewMessage != null) {
          try {
            final message = MessageModel.fromJson(data);
            onNewMessage!(message);
          } catch (e) {
            print('Error parsing new message: $e');
          }
        }
      });

      _socket!.on('message_sent', (data) {
        print('✅ Message sent confirmed');
        if (onMessageSent != null) {
          try {
            final message = MessageModel.fromJson(data);
            onMessageSent!(message);
          } catch (e) {
            print('Error parsing message sent: $e');
          }
        }
      });

      _socket!.on('message_read', (data) {
        print('👁️ Message read: ${data['messageId']}');
        if (onMessageRead != null && data['messageId'] != null) {
          final readAt = data['readAt'] != null
              ? DateTime.parse(data['readAt'])
              : DateTime.now();
          onMessageRead!(data['messageId'], readAt);
        }
      });

      _socket!.on('conversation_read', (data) {
        print('👁️ Conversation read: ${data['conversationId']}');
        if (onConversationRead != null) {
          onConversationRead!(
            data['conversationId'],
            data['userId'],
          );
        }
      });

      _socket!.on('user_typing', (data) {
        if (onUserTyping != null) {
          onUserTyping!(
            data['conversationId'],
            data['userId'],
            data['isTyping'] ?? false,
          );
        }
      });

      _socket!.on('user_online', (data) {
        print('🟢 User online: ${data['userId']}');
        if (onUserOnline != null) {
          onUserOnline!(data['userId']);
        }
      });

      _socket!.on('user_offline', (data) {
        print('⚫ User offline: ${data['userId']}');
        if (onUserOffline != null) {
          onUserOffline!(data['userId']);
        }
      });

      _socket!.on('error', (data) {
        print('❌ Socket error: ${data['message']}');
        if (onError != null) {
          onError!(data['message'] ?? 'Có lỗi xảy ra');
        }
      });

    } catch (e) {
      print('Socket connection error: $e');
      if (onError != null) {
        onError!('Lỗi kết nối: $e');
      }
    }
  }

  // Ngắt kết nối
  void disconnect() {
    print('Disconnecting socket...');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // Gửi tin nhắn
  void sendMessage({
    required String conversationId,
    required String content,
  }) {
    if (!isConnected) {
      print('Socket not connected');
      if (onError != null) {
        onError!('Chưa kết nối server');
      }
      return;
    }

    print('Sending message: $content');
    _socket!.emit('send_message', {
      'conversationId': conversationId,
      'content': content,
    });
  }

  // Đánh dấu đã đọc một tin nhắn
  void markMessageAsRead(String messageId) {
    if (!isConnected) return;

    _socket!.emit('mark_read', {
      'messageId': messageId,
    });
  }

  // Đánh dấu đã đọc toàn bộ conversation
  void markConversationAsRead(String conversationId) {
    if (!isConnected) return;

    _socket!.emit('mark_conversation_read', {
      'conversationId': conversationId,
    });
  }

  // Gửi typing indicator
  void sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) {
    if (!isConnected) return;

    _socket!.emit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  // Clear all callbacks (khi dispose widget)
  void clearCallbacks() {
    onNewMessage = null;
    onMessageSent = null;
    onMessageRead = null;
    onConversationRead = null;
    onUserTyping = null;
    onUserOnline = null;
    onUserOffline = null;
    onError = null;
  }
}
