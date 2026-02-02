class ConversationModel {
  final String id;
  final OtherUserModel otherUser;
  final LastMessageModel? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  ConversationModel({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      otherUser: OtherUserModel.fromJson(json['otherUser']),
      lastMessage: json['lastMessage'] != null
          ? LastMessageModel.fromJson(json['lastMessage'])
          : null,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'otherUser': otherUser.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class OtherUserModel {
  final String id;
  final String role;
  final String? email;
  final String? phoneNumber;
  final UserProfileModel? profile;

  OtherUserModel({
    required this.id,
    required this.role,
    this.email,
    this.phoneNumber,
    this.profile,
  });

  factory OtherUserModel.fromJson(Map<String, dynamic> json) {
    return OtherUserModel(
      id: json['id'],
      role: json['role'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profile: json['profile'] != null
          ? UserProfileModel.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'email': email,
      'phoneNumber': phoneNumber,
      'profile': profile?.toJson(),
    };
  }
}

class UserProfileModel {
  final String? fullName;
  final String? organizationName;
  final String? avatarUrl;
  final String? organizationId;
  final String? organizationStatus;

  UserProfileModel({
    this.fullName,
    this.organizationName,
    this.avatarUrl,
    this.organizationId,
    this.organizationStatus,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      fullName: json['fullName'],
      organizationName: json['organizationName'],
      avatarUrl: json['avatarUrl'],
      organizationId: json['organizationId'],
      organizationStatus: json['organizationStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'organizationName': organizationName,
      'avatarUrl': avatarUrl,
      'organizationId': organizationId,
      'organizationStatus': organizationStatus,
    };
  }

  String get displayName {
    if (organizationName != null) return organizationName!;
    if (fullName != null) return fullName!;
    return 'User';
  }
}

class LastMessageModel {
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String senderId;

  LastMessageModel({
    required this.content,
    required this.createdAt,
    required this.isRead,
    required this.senderId,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'],
      senderId: json['senderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'senderId': senderId,
    };
  }
}
