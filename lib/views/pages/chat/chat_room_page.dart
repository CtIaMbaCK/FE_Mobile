import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../models/chat/conversation_model.dart';
import '../../../models/chat/message_model.dart';
import '../../../services/chat/chat_api_service.dart';
import '../../../services/chat/chat_socket_service.dart';

class ChatRoomPage extends StatefulWidget {
  final ConversationModel conversation;

  const ChatRoomPage({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ChatApiService _apiService = ChatApiService();
  final ChatSocketService _socketService = ChatSocketService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isOtherUserTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Setup socket callbacks
    _socketService.onNewMessage = (message) {
      if (message.conversationId == widget.conversation.id) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
        // Mark as read
        _socketService.markMessageAsRead(message.id);
      }
    };

    _socketService.onMessageSent = (message) {
      // Message đã được thêm vào list rồi (optimistic update)
      // Chỉ cần update id
      setState(() {
        final index = _messages.indexWhere((m) => m.id == 'temp');
        if (index != -1) {
          _messages[index] = message;
        }
      });
    };

    _socketService.onUserTyping = (conversationId, userId, isTyping) {
      if (conversationId == widget.conversation.id &&
          userId == widget.conversation.otherUser.id) {
        setState(() {
          _isOtherUserTyping = isTyping;
        });
      }
    };

    // Load messages
    await _loadMessages();

    // Mark conversation as read
    _socketService.markConversationAsRead(widget.conversation.id);
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _apiService.getMessages(
        conversationId: widget.conversation.id,
      );

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Load messages error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải tin nhắn: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    // Optimistic update
    final tempMessage = MessageModel(
      id: 'temp',
      conversationId: widget.conversation.id,
      senderId: 'me', // Placeholder
      content: content,
      isRead: false,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(tempMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    // Send via socket
    _socketService.sendMessage(
      conversationId: widget.conversation.id,
      content: content,
    );

    setState(() {
      _isSending = false;
    });

    // Stop typing indicator
    _socketService.sendTypingIndicator(
      conversationId: widget.conversation.id,
      isTyping: false,
    );
  }

  void _onTyping() {
    // Cancel previous timer
    _typingTimer?.cancel();

    // Send typing = true
    _socketService.sendTypingIndicator(
      conversationId: widget.conversation.id,
      isTyping: true,
    );

    // Set timer to send typing = false after 2 seconds
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _socketService.sendTypingIndicator(
        conversationId: widget.conversation.id,
        isTyping: false,
      );
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    // Clear callbacks nhưng không disconnect socket
    _socketService.onNewMessage = null;
    _socketService.onMessageSent = null;
    _socketService.onUserTyping = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = widget.conversation.otherUser;
    final profile = otherUser.profile;

    String displayName = 'User';
    if (otherUser.role == 'ADMIN') {
      displayName = 'Admin BetterUS';
    } else if (profile != null) {
      displayName = profile.displayName;
    }

    String? avatarUrl = profile?.avatarUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF008080),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                      displayName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF008080),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // if (_isOtherUserTyping)
                  //   const Text(
                  //     'Đang nhập...',
                  //     style: TextStyle(
                  //       color: Colors.white70,
                  //       fontSize: 12,
                  //     ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Menu 3 chấm - chỉ hiện khi không phải Admin
          if (otherUser.role != 'ADMIN')
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'info') {
                  _showUserInfo();
                } else if (value == 'join' &&
                    otherUser.role == 'ORGANIZATION' &&
                    (profile?.organizationId == null ||
                        profile?.organizationStatus != 'APPROVED')) {
                  _requestJoinOrganization();
                }
              },
              itemBuilder: (context) {
                final items = <PopupMenuEntry<String>>[
                  const PopupMenuItem(
                    value: 'info',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 12),
                        Text('Thông tin'),
                      ],
                    ),
                  ),
                ];

                // Hiển thị "Tham gia TCXH" nếu chưa tham gia
                if (otherUser.role == 'ORGANIZATION' &&
                    (profile?.organizationId == null ||
                        profile?.organizationStatus != 'APPROVED')) {
                  items.add(
                    const PopupMenuItem(
                      value: 'join',
                      child: Row(
                        children: [
                          Icon(Icons.group_add),
                          SizedBox(width: 12),
                          Text('Tham gia TCXH'),
                      ],
                    ),
                  ),
                );
              }

              return items;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
          ),

          // Typing indicator
          if (_isOtherUserTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '...',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _onTyping();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF008080)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF008080),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            'Chưa có tin nhắn nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gửi tin nhắn đầu tiên!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    // Kiểm tra xem tin nhắn có phải của mình không
    // Nếu senderId khác với otherUser.id thì là của mình
    final isMe = message.senderId != widget.conversation.otherUser.id;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF008080) : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.createdAt),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.lightBlueAccent : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserInfo() {
    final otherUser = widget.conversation.otherUser;
    final profile = otherUser.profile;

    // Lấy display name
    String displayName = 'User';
    if (otherUser.role == 'VOLUNTEER' || otherUser.role == 'BENEFICIARY') {
      displayName = profile?.fullName ?? 'User';
    } else if (otherUser.role == 'ORGANIZATION') {
      displayName = profile?.organizationName ?? 'Tổ chức';
    } else if (otherUser.role == 'ADMIN') {
      displayName = 'Admin BetterUS';
    }

    // Role badge
    Map<String, dynamic> getRoleBadge() {
      if (otherUser.role == 'VOLUNTEER') return {'text': 'TNV', 'color': Colors.green};
      if (otherUser.role == 'BENEFICIARY') return {'text': 'NCGĐ', 'color': Colors.orange};
      if (otherUser.role == 'ORGANIZATION') return {'text': 'TCXH', 'color': Colors.blue};
      if (otherUser.role == 'ADMIN') return {'text': 'ADMIN', 'color': Colors.red};
      return {'text': 'USER', 'color': Colors.grey};
    }

    final badge = getRoleBadge();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF008080),
              backgroundImage: profile?.avatarUrl != null
                  ? NetworkImage(profile!.avatarUrl!)
                  : null,
              child: profile?.avatarUrl == null
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badge['color'],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge['text'],
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email
              if (otherUser.email != null) ...[
                _buildInfoRow(Icons.email_outlined, 'Email', otherUser.email!),
                const SizedBox(height: 12),
              ],

              // Số điện thoại
              if (otherUser.phoneNumber != null) ...[
                _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', otherUser.phoneNumber!),
                const SizedBox(height: 12),
              ],

              // Thông tin profile
              if (profile != null) ...[
                // TNV/NCGĐ
                if (profile.fullName != null) ...[
                  _buildInfoRow(Icons.person_outline, 'Họ tên', profile.fullName!),
                  const SizedBox(height: 12),
                ],

                // TCXH
                if (profile.organizationName != null) ...[
                  _buildInfoRow(Icons.business_outlined, 'Tên tổ chức', profile.organizationName!),
                  const SizedBox(height: 12),
                ],

                // Organization status
                if (profile.organizationId != null) ...[
                  _buildInfoRow(
                    Icons.group_outlined,
                    'Trạng thái TCXH',
                    profile.organizationStatus == 'PENDING'
                        ? 'Chờ duyệt'
                        : profile.organizationStatus == 'ACTIVE'
                            ? 'Đã tham gia'
                            : profile.organizationStatus ?? 'Chưa tham gia',
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF008080),
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _requestJoinOrganization() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tham gia TCXH'),
        content: const Text('Bạn có muốn gửi yêu cầu tham gia tổ chức này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.requestJoinOrganization(
          widget.conversation.otherUser.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi yêu cầu tham gia tổ chức thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
