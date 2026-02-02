import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/chat/conversation_model.dart';
import '../../../services/chat/chat_api_service.dart';
import '../../../services/chat/chat_socket_service.dart';
import 'chat_room_page.dart';
import 'user_search_dialog.dart';

class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  final ChatApiService _apiService = ChatApiService();
  final ChatSocketService _socketService = ChatSocketService();

  List<ConversationModel> _conversations = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Kết nối socket
    await _socketService.connect();

    // Setup callbacks
    _socketService.onNewMessage = (message) {
      // Khi có tin nhắn mới, reload conversations
      _loadConversations();
      _loadUnreadCount();
    };

    _socketService.onMessageSent = (message) {
      // Khi gửi tin nhắn thành công, reload
      _loadConversations();
    };

    // Auto-create conversation với Admin
    await _apiService.ensureAdminConversation();

    // Load data
    await _loadConversations();
    await _loadUnreadCount();
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await _apiService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Load conversations error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách: $e')),
        );
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _apiService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      print('Load unread count error: $e');
    }
  }

  @override
  void dispose() {
    // Không disconnect socket ở đây vì có thể dùng chung cho nhiều page
    // Chỉ clear callbacks
    _socketService.clearCallbacks();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF008080),
        elevation: 0,
        title: const Text(
          'Tin nhắn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Unread count badge
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) => const UserSearchDialog(),
              );

              if (result != null) {
                // User đã chọn một user để chat
                // Reload conversations để hiển thị conversation mới
                _loadConversations();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadConversations();
          await _loadUnreadCount();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _conversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return _buildConversationItem(conversation);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có cuộc hội thoại nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút tìm kiếm để bắt đầu chat',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(ConversationModel conversation) {
    final otherUser = conversation.otherUser;
    final profile = otherUser.profile;
    final lastMessage = conversation.lastMessage;

    // Lấy display name
    String displayName = 'User';
    if (otherUser.role == 'ADMIN') {
      displayName = 'Admin BetterUS';
    } else if (profile != null) {
      displayName = profile.displayName;
    }

    // Avatar
    String? avatarUrl = profile?.avatarUrl;

    // Last message text
    String lastMessageText = lastMessage?.content ?? 'Chưa có tin nhắn';
    bool isUnread = lastMessage != null &&
                    !lastMessage.isRead &&
                    lastMessage.senderId != otherUser.id;

    // Time
    String timeText = '';
    if (conversation.lastMessageAt != null) {
      final now = DateTime.now();
      final messageTime = conversation.lastMessageAt!;
      final difference = now.difference(messageTime);

      if (difference.inDays == 0) {
        timeText = DateFormat('HH:mm').format(messageTime);
      } else if (difference.inDays == 1) {
        timeText = 'Hôm qua';
      } else if (difference.inDays < 7) {
        timeText = '${difference.inDays} ngày trước';
      } else {
        timeText = DateFormat('dd/MM').format(messageTime);
      }
    }

    return InkWell(
      onTap: () async {
        // Mở chat room
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              conversation: conversation,
            ),
          ),
        );

        // Reload khi quay lại
        _loadConversations();
        _loadUnreadCount();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF008080),
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      displayName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnread
                              ? const Color(0xFF008080)
                              : Colors.grey[600],
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessageText,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUnread
                                ? Colors.black87
                                : Colors.grey[600],
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF008080),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
