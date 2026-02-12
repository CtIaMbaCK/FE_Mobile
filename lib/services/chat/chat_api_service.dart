import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/chat/conversation_model.dart';
import '../../models/chat/message_model.dart';

class ChatApiService {
  static const String baseUrl = 'https://frettiest-ariella-unnationally.ngrok-free.dev/api/v1';
  final _storage = const FlutterSecureStorage();

  // Timeout cho các requests (quan trọng cho 4G)
  static const Duration _requestTimeout = Duration(seconds: 15);

  // Helper: Lấy headers với token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== USERS & SEARCH ====================

  // Tìm kiếm users
  Future<List<dynamic>> searchUsers(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) return [];

      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/chat/search-users?q=${Uri.encodeComponent(searchTerm)}');

      print('Searching users: $searchTerm');
      final response = await http.get(uri, headers: headers).timeout(
        _requestTimeout,
        onTimeout: () {
          throw Exception('Kết nối quá chậm. Vui lòng kiểm tra mạng 4G.');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Found ${data.length} users');
        return data;
      } else {
        print('Search users error: ${response.statusCode}');
        throw Exception('Lỗi tìm kiếm: ${response.statusCode}');
      }
    } catch (e) {
      print('Search users exception: $e');
      throw Exception('Lỗi tìm kiếm: $e');
    }
  }

  // Lấy thông tin Admin (Public endpoint - không cần token)
  Future<Map<String, dynamic>?> getAdminUser() async {
    try {
      final uri = Uri.parse('$baseUrl/chat/admin-user');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Get admin error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Get admin exception: $e');
      return null;
    }
  }

  // ==================== CONVERSATIONS ====================

  // Lấy danh sách conversations
  Future<List<ConversationModel>> getConversations() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/chat/conversations');

      print('Fetching conversations...');
      final response = await http.get(uri, headers: headers).timeout(
        _requestTimeout,
        onTimeout: () {
          throw Exception('Kết nối quá chậm. Vui lòng kiểm tra mạng.');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Got ${data.length} conversations');
        return data.map((json) => ConversationModel.fromJson(json)).toList();
      } else {
        print('Get conversations error: ${response.statusCode}');
        throw Exception('Lỗi tải danh sách: ${response.statusCode}');
      }
    } catch (e) {
      print('Get conversations exception: $e');
      rethrow;
    }
  }

  // Tạo hoặc lấy conversation
  Future<ConversationModel> createOrGetConversation(String targetUserId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/chat/conversations');

      print('Creating conversation with: $targetUserId');
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({'targetUserId': targetUserId}),
      ).timeout(
        _requestTimeout,
        onTimeout: () {
          throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Conversation created/found');
        return ConversationModel.fromJson(data);
      } else {
        print('Create conversation error: ${response.statusCode}');
        throw Exception('Lỗi tạo hội thoại: ${response.statusCode}');
      }
    } catch (e) {
      print('Create conversation exception: $e');
      rethrow;
    }
  }

  // Auto-create conversation với Admin khi vào Chat tab
  Future<void> ensureAdminConversation() async {
    try {
      // Lấy thông tin Admin (public API)
      final admin = await getAdminUser();
      if (admin == null || admin['id'] == null) {
        print('Admin user not found');
        return;
      }

      // Tạo conversation với Admin (nếu chưa có)
      await createOrGetConversation(admin['id']);
      print('✅ Admin conversation ensured');
    } catch (e) {
      print('Ensure admin conversation error: $e');
      // Silent fail - không block app
    }
  }

  // ==================== MESSAGES ====================

  // Lấy tin nhắn trong conversation
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/chat/messages?conversationId=$conversationId&page=$page&limit=$limit',
      );

      print('Fetching messages for conversation: $conversationId (page $page)');
      final response = await http.get(uri, headers: headers).timeout(
        _requestTimeout,
        onTimeout: () {
          throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Got ${data.length} messages');
        return data.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        print('Get messages error: ${response.statusCode}');
        throw Exception('Lỗi tải tin nhắn: ${response.statusCode}');
      }
    } catch (e) {
      print('Get messages exception: $e');
      rethrow;
    }
  }

  // Đánh dấu đã đọc conversation (REST API fallback)
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/chat/conversations/$conversationId/mark-read');

      final response = await http.patch(uri, headers: headers);

      if (response.statusCode != 200) {
        print('Mark read error: ${response.statusCode}');
      }
    } catch (e) {
      print('Mark read exception: $e');
    }
  }

  // ==================== UNREAD COUNT ====================

  // Lấy số tin nhắn chưa đọc
  Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/chat/unread-count');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unreadCount'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Get unread count exception: $e');
      return 0;
    }
  }

  // ==================== ORGANIZATION ====================

  // Gửi yêu cầu tham gia TCXH
  Future<bool> requestJoinOrganization(String organizationId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/chat/join-organization');

      print('Requesting to join organization: $organizationId');
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({'organizationId': organizationId}),
      ).timeout(
        _requestTimeout,
        onTimeout: () {
          throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Join organization request sent successfully');
        return true;
      } else {
        final error = json.decode(response.body);
        print('Join organization error: ${error['message']}');
        throw Exception(error['message'] ?? 'Lỗi gửi yêu cầu');
      }
    } catch (e) {
      print('Join organization exception: $e');
      rethrow;
    }
  }
}
