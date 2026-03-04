import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/chat/message_model.dart';
import '../../utils/date_utils.dart';

class ChatSocketService {
  static final ChatSocketService _instance = ChatSocketService._internal();
  factory ChatSocketService() => _instance;
  ChatSocketService._internal();

  IO.Socket? _socket;
  final _storage = const FlutterSecureStorage();

  // Base URL - cần update theo ngrok URL của bạn
  static const String _baseUrl =
      'https://frettiest-ariella-unnationally.ngrok-free.dev';

  // Callbacks
  Function(MessageModel)? onNewMessage;
  Function(MessageModel)? onMessageSent;
  Function(String messageId, DateTime readAt)? onMessageRead;
  Function(String conversationId, String userId)? onConversationRead;
  Function(String conversationId, String userId, bool isTyping)? onUserTyping;
  Function(String userId)? onUserOnline;
  Function(String userId)? onUserOffline;
  Function(String error)? onError;

  // SOS Emergency callbacks
  Function(Map<String, dynamic>)? onSOSSent;
  Function(Map<String, dynamic>)? onSOSAlert;

  bool get isConnected => _socket?.connected ?? false;

  // Connection state
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // Kết nối Socket.io
  Future<void> connect() async {
    // Prevent multiple simultaneous connection attempts
    if (_isConnecting) {
      print('Socket connection already in progress');
      return;
    }

    if (_socket?.connected ?? false) {
      print('Socket already connected');
      return;
    }

    _isConnecting = true;

    try {
      // Lấy token từ secure storage
      final token = await _storage.read(key: 'token');

      if (token == null || token.isEmpty) {
        print('No token found for socket connection');
        _isConnecting = false;
        return;
      }

      print('Connecting to socket at: $_baseUrl/chat');

      _socket = IO.io(
        '$_baseUrl/chat',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({'token': token})
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true',
            })
            // Thêm timeout để tránh treo khi mạng 4G chậm
            .setTimeout(10000) // 10 seconds timeout
            // Thêm reconnection settings
            .enableReconnection()
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setReconnectionDelay(_reconnectDelay.inMilliseconds)
            .setReconnectionDelayMax(10000) // Max 10s between attempts
            .build(),
      );

      // Connection events
      _socket!.onConnect((_) {
        print('✅ Socket connected! ID: ${_socket!.id}');
        _isConnecting = false;
        _reconnectAttempts = 0; // Reset counter on successful connection
      });

      _socket!.onConnectError((data) {
        print('❌ Socket connect error: $data');
        _isConnecting = false;
        _reconnectAttempts++;

        if (onError != null) {
          if (_reconnectAttempts >= _maxReconnectAttempts) {
            onError!(
              'Không thể kết nối server. Vui lòng kiểm tra kết nối mạng.',
            );
          } else {
            onError!(
              'Đang thử kết nối lại... (${_reconnectAttempts}/$_maxReconnectAttempts)',
            );
          }
        }
      });

      _socket!.onDisconnect((reason) {
        print('❌ Socket disconnected: $reason');
        _isConnecting = false;

        // Auto reconnect on certain disconnect reasons
        if (reason == 'transport close' || reason == 'ping timeout') {
          print('⚠️ Network issue detected, will auto-reconnect...');
        }
      });

      _socket!.onReconnect((attempt) {
        print('🔄 Socket reconnected after $attempt attempts');
        _reconnectAttempts = 0;
      });

      _socket!.onReconnectAttempt((attempt) {
        print('🔄 Reconnect attempt $attempt/$_maxReconnectAttempts');
      });

      _socket!.onReconnectError((data) {
        print('❌ Reconnect error: $data');
      });

      _socket!.onReconnectFailed((_) {
        print('❌ Reconnection failed after $_maxReconnectAttempts attempts');
        _isConnecting = false;
        if (onError != null) {
          onError!('Không thể kết nối server. Vui lòng thử lại sau.');
        }
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
              ? DateTimeUtils.parseFromApi(data['readAt'])
              : DateTime.now();
          onMessageRead!(data['messageId'], readAt);
        }
      });

      _socket!.on('conversation_read', (data) {
        print('👁️ Conversation read: ${data['conversationId']}');
        if (onConversationRead != null) {
          onConversationRead!(data['conversationId'], data['userId']);
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

      // SOS Emergency events
      _socket!.on('sos_sent', (data) {
        print('🚨 SOS sent confirmation: $data');
        if (onSOSSent != null) {
          onSOSSent!(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('sos_alert', (data) {
        print('🚨 SOS Alert received: $data');
        if (onSOSAlert != null) {
          onSOSAlert!(Map<String, dynamic>.from(data));
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
    _isConnecting = false;
    _reconnectAttempts = 0;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // Tái khởi động socket với token mới (dùng khi đổi tài khoản)
  Future<void> reinitialize() async {
    print('🔄 Re-initializing socket with new token...');
    disconnect();
    clearCallbacks();
    await Future.delayed(const Duration(milliseconds: 300));
    await connect();
  }

  // Kết nối lại thủ công (dùng khi mạng trở lại)
  Future<void> reconnect() async {
    print('🔄 Manual reconnect requested');
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }

  // Kiểm tra trạng thái kết nối và thử kết nối lại nếu cần
  Future<void> ensureConnected() async {
    if (!isConnected && !_isConnecting) {
      print('⚠️ Socket not connected, attempting to reconnect...');
      await connect();
    }
  }

  // Gửi tin nhắn
  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    // Đảm bảo socket đã kết nối
    await ensureConnected();

    if (!isConnected) {
      print('Socket not connected after ensure');
      if (onError != null) {
        onError!('Không thể kết nối server. Vui lòng kiểm tra mạng.');
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

    _socket!.emit('mark_read', {'messageId': messageId});
  }

  // Đánh dấu đã đọc toàn bộ conversation
  void markConversationAsRead(String conversationId) {
    if (!isConnected) return;

    _socket!.emit('mark_conversation_read', {'conversationId': conversationId});
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

  // Gửi SOS Emergency
  Future<void> sendSOS({String? notes}) async {
    // Đảm bảo socket đã kết nối
    await ensureConnected();

    if (!isConnected) {
      print('Socket not connected for SOS');
      if (onError != null) {
        onError!('Không thể kết nối server. Vui lòng kiểm tra mạng.');
      }
      return;
    }

    print('🚨 Sending SOS emergency signal...');
    _socket!.emit('send_sos', {if (notes != null) 'notes': notes});
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
    onSOSSent = null;
    onSOSAlert = null;
  }
}
